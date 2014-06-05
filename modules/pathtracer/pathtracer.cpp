#undef NDEBUG

// ospray
#include "pathtracer.h"
#include "pathtracer_ispc.h"

namespace ospray {
  PathTracer::PathTracer()
  {
    const int32 maxDepth = 20;
    const float minContribution = .01f;
    const float epsilon = 1e-3f;
    const int32 numSPP = 16;
    void *backplate = NULL;
    ispcEquivalent = ispc::PathTracer_create(maxDepth,minContribution,epsilon,
                                             numSPP,backplate);

  }

  /*! \brief create a material of given type */
  Material *PathTracer::createMaterial(const char *type) 
  { 
    std::string ptType = std::string("PathTracer_")+type;
    Material *material = Material::createMaterial(ptType.c_str());
    if (!material) 
      throw std::runtime_error("invalid path tracer material "+std::string(type)); 
    material->refInc();
    return material;
  }

  void PathTracer::RenderTask::renderTile(Tile &tile)
  {
    ispc::PathTracer_renderTile((ispc::Tile &)tile,
                                pathtracer->getIE());
  }

  void PathTracer::commit() 
  {
    model = (Model*)getParamObject("world",NULL);
    model = (Model*)getParamObject("model",model.ptr);
    if (!model) 
      throw std::runtime_error("path tracer doesn't have a model");
    ispc::PathTracer_setModel(getIE(),model->getIE());

    camera = (Camera*)getParamObject("camera",NULL);
    if (!camera) 
      throw std::runtime_error("path tracer doesn't have a camera");
    ispc::PathTracer_setCamera(getIE(),camera->getIE());
  }
  TileRenderer::RenderJob *PathTracer::createRenderJob(FrameBuffer *fb)
  { 
    ispc::PathTracer_renderFrameInit(getIE());
    return new RenderTask(this); 
  }

  OSP_REGISTER_RENDERER(PathTracer,pathtracer);
};

