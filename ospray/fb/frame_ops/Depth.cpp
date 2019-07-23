// ======================================================================== //
// Copyright 2009-2019 Intel Corporation                                    //
//                                                                          //
// Licensed under the Apache License, Version 2.0 (the "License");          //
// you may not use this file except in compliance with the License.         //
// You may obtain a copy of the License at                                  //
//                                                                          //
//     http://www.apache.org/licenses/LICENSE-2.0                           //
//                                                                          //
// Unless required by applicable law or agreed to in writing, software      //
// distributed under the License is distributed on an "AS IS" BASIS,        //
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. //
// See the License for the specific language governing permissions and      //
// limitations under the License.                                           //
// ======================================================================== //

// ospray
#include "../FrameBufferView.h"
#include "../ImageOp.h"
// ospcommon
#include "ospcommon/tasking/parallel_for.h"
// std
#include <algorithm>

namespace ospray {

  //! Depth frameop replaces the color data with a normalized depth buffer img
  struct OSPRAY_SDK_INTERFACE DepthFrameOp : public FrameOp
  {
    std::unique_ptr<LiveImageOp> attach(FrameBufferView &fbView) override;

    std::string toString() const override;
  };

  struct OSPRAY_SDK_INTERFACE LiveDepthFrameOp : public LiveFrameOp
  {
    LiveDepthFrameOp(FrameBufferView &fbView);

    void process(const Camera *) override;
  };

  // Definitions //////////////////////////////////////////////////////////////

  std::unique_ptr<LiveImageOp> DepthFrameOp::attach(FrameBufferView &fbView)
  {
    if (!fbView.colorBuffer || !fbView.depthBuffer) {
      static WarnOnce warn(toString() +
                           " requires color and depth data but "
                           "the framebuffer does not have these channels.");
      throw std::runtime_error(toString() +
                               " requires color and depth but "
                               "the framebuffer does not have these channels");
    }
    return ospcommon::make_unique<LiveDepthFrameOp>(fbView);
  }

  std::string DepthFrameOp::toString() const
  {
    return "ospray::DepthFrameOp";
  }

  LiveDepthFrameOp::LiveDepthFrameOp(FrameBufferView &_fbView)
      : LiveFrameOp(_fbView)
  {
  }

  void LiveDepthFrameOp::process(const Camera *)
  {
    // First find the min/max depth range to normalize the image,
    // we don't use minmax_element here b/c we don't want inf to be
    // found as the max depth value
    const int numPixels = fbView.fbDims.x * fbView.fbDims.y;
    vec2f depthRange(std::numeric_limits<float>::infinity(),
                     -std::numeric_limits<float>::infinity());
    for (int i = 0; i < numPixels; ++i) {
      if (!std::isinf(fbView.depthBuffer[i])) {
        depthRange.x = std::min(depthRange.x, fbView.depthBuffer[i]);
        depthRange.y = std::max(depthRange.y, fbView.depthBuffer[i]);
      }
    }
    const float denom = 1.f / (depthRange.y - depthRange.x);

    tasking::parallel_for(numPixels, [&](int px) {
      float normalizedZ = 1.f;
      if (!std::isinf(fbView.depthBuffer[px]))
        normalizedZ = (fbView.depthBuffer[px] - depthRange.x) * denom;

      for (int c = 0; c < 3; ++c) {
        if (fbView.colorBufferFormat == OSP_FB_RGBA8 ||
            fbView.colorBufferFormat == OSP_FB_SRGBA) {
          uint8_t *cbuf    = static_cast<uint8_t *>(fbView.colorBuffer);
          cbuf[px * 4 + c] = static_cast<uint8_t>(normalizedZ * 255.f);
        } else {
          float *cbuf      = static_cast<float *>(fbView.colorBuffer);
          cbuf[px * 4 + c] = normalizedZ;
        }
      }
      if (fbView.albedoBuffer) {
        fbView.albedoBuffer[px] = vec3f(normalizedZ);
      }
    });
  }

  OSP_REGISTER_IMAGE_OP(DepthFrameOp, frame_depth);

}  // namespace ospray
