## Copyright 2009-2020 Intel Corporation
## SPDX-License-Identifier: Apache-2.0

set(COMPONENT_NAME openvkl)

set(COMPONENT_PATH ${INSTALL_DIR_ABSOLUTE})
if (INSTALL_IN_SEPARATE_DIRECTORIES)
  set(COMPONENT_PATH ${INSTALL_DIR_ABSOLUTE}/${COMPONENT_NAME})
endif()

if(OPENVKL_ROOT)
  set(OPENVKL_SOURCE_DIR ${OPENVKL_ROOT})
  set(OPENVKL_URL)
  message(STATUS "Using customized OpenVKL from ${OPENVKL_SOURCE_DIR}")
else()
  set(OPENVKL_SOURCE_DIR ${COMPONENT_NAME}/src)
  set(OPENVKL_URL URL "http://github.com/openvkl/openvkl/archive/${BUILD_OPENVKL_VERSION}.zip")
endif()

ExternalProject_Add(${COMPONENT_NAME}
  PREFIX ${COMPONENT_NAME}
  DOWNLOAD_DIR ${COMPONENT_NAME}
  STAMP_DIR ${COMPONENT_NAME}/stamp
  SOURCE_DIR ${OPENVKL_SOURCE_DIR}
  BINARY_DIR ${COMPONENT_NAME}/build
  LIST_SEPARATOR | # Use the alternate list separator
  ${OPENVKL_URL}
  CMAKE_ARGS
    -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_INSTALL_PREFIX:PATH=${COMPONENT_PATH}
    -DCMAKE_INSTALL_INCLUDEDIR=${CMAKE_INSTALL_INCLUDEDIR}
    -DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR}
    -DCMAKE_INSTALL_DOCDIR=${CMAKE_INSTALL_DOCDIR}
    -DCMAKE_INSTALL_BINDIR=${CMAKE_INSTALL_BINDIR}
    -DCMAKE_BUILD_TYPE=${DEPENDENCIES_BUILD_TYPE}
    $<$<BOOL:${DOWNLOAD_TBB}>:-DRKCOMMON_TBB_ROOT=${TBB_PATH}>
    $<$<BOOL:${DOWNLOAD_ISPC}>:-DISPC_EXECUTABLE=${ISPC_PATH}>
    -DBUILD_BENCHMARKS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTING=OFF
  BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
  BUILD_ALWAYS ${ALWAYS_REBUILD}
)

list(APPEND CMAKE_PREFIX_PATH ${COMPONENT_PATH})
string(REPLACE ";" "|" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")

ExternalProject_Add_StepDependencies(${COMPONENT_NAME}
  configure
    rkcommon
    embree
    $<$<BOOL:${DOWNLOAD_ISPC}>:ispc>
)