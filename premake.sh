#! /bin/bash

# change this block to fit your environment
OSPROOT=~/software
SRCROOT=$(pwd)

# TBB component
export TBB_ROOT=${OSPROOT}/tbb2017_20170604oss
LOAD_TBB()
{
    export LD_LIBRARY_PATH=${TBB_ROOT}/lib/intel64/gcc4.7:${LD_LIBRARY_PATH}
    source ${TBB_ROOT}/bin/tbbvars.sh intel64
}

# ispc component
export ISPC_ROOT=${OSPROOT}/ispc-v1.9.1-linux
LOAD_ISPC()
{
    export PATH=${ISPC_ROOT}:${PATH}
}

# Embree component
export EMBREE_ROOT=${OSPROOT}/embree-2.15.0.x86_64.linux
LOAD_EMBREE()
{
    # CMAKEARGS=${CMAKEARGS}" -DOSPRAY_USE_EXTERNAL_EMBREE=ON"
    export embree_DIR=${EMBREE_ROOT}
    source ${EMBREE_ROOT}/embree-vars.sh
}

#ICC
INTELICC_PATH=/opt/intel/bin/icc

#GCC
USE_GCC=1
GCC_PATH=$(which gcc)
GXX_PATH=$(which g++)

# QT path
QT_PATH=${OSPROOT}/qt-4.8.6/qt-everywhere-opensource-src-4.8.6-install

# initialization
CUSTOMIZED_PROJSUFFIX=""
PROJSUFFIX=""
PROJPREFIX="./"
CMAKEARGS=" -DOSPRAY_MODULE_VISIT=ON" # enable visit module by default XD
CMAKEPATH="cmake"

HELP()
{
    echo
    echo " This is the OSPRay building helper written by Qi, WU"
    echo
    echo "--- In order to compile the program, you need:"
    echo "---  1) one computer with descent Intel CPU"
    echo "---  2) some required libraries:"
    echo "---     Embree: https://embree.github.io/"
    echo "---     TBB:    https://ispc.github.io/"
    echo "---     ISPC:   https://www.threadingbuildingblocks.org/"
    echo "---     >> download their newest version"
    echo "---        and change pathes in this file"
    echo "Usage build.sh [OPTION]"
    echo
    echo "Description:"
    echo "generate build directory and makefiles for OSPRay"
    echo 
    echo "Option list:"
    echo "  -h , --help         Print help message"
    echo "  -m , --mpi          Build with MPI"
    echo "  -a , --cmake-args   Build with additional cmake arguments"
    echo "  -ic, --intel-icc    Build with intel ICC"
    echo "  -im, --image-magick Build with image magick"
    echo "  -qt, --qt           Build with Qt"
    echo "  -o , --output-dir   Build directory name"
    echo "  --build-prefix      Build directory prefix"
    echo "                        (directory name will be generated based on rules)"
    echo "  --embree-dir        Customer Embree path"
    echo "  --tbb-dir           Customer TBB path"
    echo "  --ispc-dir          Customer ISPC path"
    echo "  --icc-dir           Customer ICC path"
    echo "  --gcc-dir           Customer GCC binary path"
    echo "  --cmake-dir         Customer CMAKE path"
    echo "  --no-apps           Disable all OSPRay applications"
    echo 
}

# Stop until all parameters used up
if [ -z "$1" ]; then
    HELP
    exit
fi
until [ -z "$1" ]; do
    case "$1" in

	# --- Help 
	-h | --help)
 	    HELP
	    exit
	    ;;

	# --- Setup intel icc
	-ic | --intel-icc)
	    CMAKEARGS=${CMAKEARGS}" -DCMAKE_CXX_COMPILER=${INTELICC_PATH}"
	    CMAKEARGS=${CMAKEARGS}" -DCMAKE_C_COMPILER=${INTELICC_PATH}"
	    USE_GCC=0
	    shift 1
	    ;;
	    
	# --- Setup mpi flag
	-m  | --mpi)
	    # load information for mpi (need to make sure that we are using intel icc)
	    PROJSUFFIX=${PROJSUFFIX}_mpi
	    CMAKEARGS=${CMAKEARGS}" -DOSPRAY_MODULE_MPI=ON"
	    shift 1
	    ;;

	# --- Setup image magick
	-im | --image-magick)
	    PROJSUFFIX=${PROJSUFFIX}_imagemagick
	    CMAKEARGS=${CMAKEARGS}" -DUSE_IMAGE_MAGICK=ON"
	    shift 1
	    ;;

        # --- Qt component
	-qt | --qt)
	    export QT_ROOT=${QT_PATH}
	    export PATH=${QT_ROOT}/bin:${PATH}
	    export LD_LIBRARY_PATH=${QT_ROOT}/lib:${LD_LIBRARY_PATH}
	    PROJSUFFIX=${PROJSUFFIX}_qt
	    shift 1
	    ;;

	# --- Setup additionnnnal arguments
	-a  | --cmake-args)
	    CMAKEARGS=${CMAKEARGS}" "${2}
	    shift 2
	    ;;

	# --- setup customized project suffix
	-o | --output-dir)
	    CUSTOMIZED_PROJSUFFIX=${2}
	    shift 2
	    ;;

	# --- Setup external libraries
	--embree-dir)
	    export EMBREE_ROOT=${2}
	    echo "user-defined embree path ${EMBREE_ROOT}"
	    shift 2
	    ;;

	--tbb-dir)
	    export TBB_ROOT=${2}
	    echo "user-defined tbb path ${TBB_ROOT}"
	    shift 2
	    ;;

	--ispc-dir)
	    export ISPC_ROOT=${2}
	    echo "user-defined ispc path ${ISPC_ROOT}"
	    shift 2
	    ;;

	--icc-dir)
	    INTELICC_PATH=${2}
	    echo "user-defined icc path ${INTELICC_PATH}"
	    shift 2
	    ;;

	--gcc-dir)
	    GCC_PATH=${2}/gcc
	    GXX_PATH=${2}/g++
	    echo "user-defined gcc path ${GCC_PATH} ${G++_PATH}"
	    shift 2
	    ;;


	--cmake-dir)
	    CMAKEPATH=${2}
	    shift 2
	    ;;

	--build-prefix)
	    PROJPREFIX=${2}
	    shift 2
	    ;;
	    
	--no-apps)
	    CMAKEARGS=${CMAKEARGS}" -DOSPRAY_ENABLE_APPS=OFF -DOSPRAY_ENABLE_MPI_APPS=OFF"
	    shift 1
	    ;;

	# --- error input
	*)
	    HELP
	    exit
	    ;;
    esac
done

# setup compiler
if [[ "${USE_GCC}" == "1" ]]; then
    CMAKEARGS=${CMAKEARGS}" -DCMAKE_CXX_COMPILER=${GXX_PATH}"
    CMAKEARGS=${CMAKEARGS}" -DCMAKE_C_COMPILER=${GCC_PATH}"    
fi

# load libraries
LOAD_TBB
LOAD_ISPC
LOAD_EMBREE
if [[ "${CUSTOMIZED_PROJSUFFIX}" == "" ]]; then
    PROJDIR=${PROJPREFIX}build${PROJSUFFIX}
else
    PROJDIR=${CUSTOMIZED_PROJSUFFIX}
fi

# debug
echo "running command: mkdir -p ${PROJDIR}"
echo "running command: cd ${PROJDIR}"
echo "running command: rm -r ./CMakeCache.txt"
echo "running command: ${CMAKEPATH} ${CMAKEARGS} ${SRCROOT}"
echo

# run actual cmake
mkdir -p ${PROJDIR}
cd ${PROJDIR}
rm -r ./CMakeCache.txt ./CMakeFiles
${CMAKEPATH} ${CMAKEARGS} ${SRCROOT}