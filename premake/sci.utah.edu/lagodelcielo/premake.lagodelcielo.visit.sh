#!/bin/bash
/home/sci/qwu/OSPRay/source/master/premake.sh  \
    --mpi \
    -o /ssd/users/qwu/ospray/build-visit \
    -i /ssd/users/qwu/ospray/install-visit \
    --embree-dir /home/sci/qwu/software/embree-3.2.0.x86_64.linux \
    --tbb-dir /home/sci/qwu/software/tbb2017_20170604oss \
    --ispc-dir /home/sci/qwu/software/ispc-v1.9.1-linux \
    --gcc \
    --gcc-exec gcc-7 g++-7 \
    --gcc-dir /usr/bin \
    --cmake-dir cmake \
    -a " -D Snappy_DIR=/home/sci/qwu/software/Lagodelcielo/snappy/install/lib64/cmake/Snappy " \
    -a " -D OSPRAY_BUILD_ISA=ALL" \
    -a " -D OSPRAY_MODULE_MPI=ON" \
    -a " -D OSPRAY_MODULE_MPI_APPS=OFF" \
    -a " -D OSPRAY_SG_CHOMBO=OFF" \
    -a " -D OSPRAY_SG_VTK=OFF" \
    -a " -D OSPRAY_SG_OPENIMAGEIO=OFF" \
    -a " -D OSPRAY_APPS_EXAMPLEVIEWER=OFF" \
    -a " -D OSPRAY_APPS_BENCHMARK=OFF" \
    -a " -D OSPRAY_MODULE_PIDX=OFF" \
    -a " -D OSPRAY_MODULE_PIDX_WORKER=OFF" \
    -a " -D OSPRAY_MODULE_PIDX_VIEWER=OFF" \
    -a " -D OSPRAY_MODULE_COSMICWEB=OFF" \
    -a " -D OSPRAY_MODULE_COSMICWEB_WORKER=OFF" \
    -a " -D OSPRAY_MODULE_COSMICWEB_VIEWER=OFF" \
    -a " -D OSPRAY_MODULE_BRICKTREE=OFF" \
    -a " -D OSPRAY_MODULE_BRICKTREE_BENCH=OFF" \
    -a " -D OSPRAY_MODULE_BRICKTREE_WIDGET=OFF" \
    -a " -D OSPRAY_MODULE_IMPLICIT_ISOSURFACES=OFF" \
    -a " -D OSPRAY_MODULE_IMPI_VIEWER=OFF" \
    -a " -D OSPRAY_MODULE_IMPI_BENCH_WIDGET=OFF" \
    -a " -D OSPRAY_MODULE_IMPI_BENCH_MARKER=OFF" \
    -a " -D OSPRAY_MODULE_TFN=OFF" \
    -a " -D OSPRAY_MODULE_TFN_WIDGET=OFF" \
    -a " -D OSPRAY_MODULE_SPLATTER=OFF" \
    -a " -D OSPRAY_MODULE_TUBES=OFF" \
    -a " -D OSPRAY_MODULE_VISIT=ON"
