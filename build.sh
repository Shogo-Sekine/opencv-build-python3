#!/bin/bash
# Setting up build env
sudo yum update -y
sudo yum install -y git cmake gcc-c++ gcc chrpath python3-devel
mkdir -p build/cv2 build/numpy
mkdir -p package
mkdir -p package/cv2 package/numpy

# Build numpy
pip install --no-cache --install-option="--prefix=$PWD/build/numpy" numpy
# installしたpipを移動
cp -rf build/numpy/lib64/python3.7/site-packages/numpy package

# Build OpenCV 4.0
(
	NUMPY=$PWD/package/numpy/core/include
	cd build
	# git clone https://github.com/Itseez/opencv.git
	cd opencv
	git checkout 4.0.0
	mkdir build
	cd build
	cmake										\
		-D CMAKE_BUILD_TYPE=RELEASE				\
		-D WITH_TBB=ON							\
		-D WITH_IPP=ON							\
		-D WITH_V4L=ON							\
		-D ENABLE_AVX=ON						\
		-D ENABLE_SSSE3=ON						\
		-D ENABLE_SSE41=ON						\
		-D ENABLE_SSE42=ON						\
		-D ENABLE_POPCNT=ON						\
		-D ENABLE_FAST_MATH=ON					\
		-D BUILD_EXAMPLES=OFF					\
		-D BUILD_TESTS=OFF						\
		-D BUILD_PERF_TESTS=OFF					\
		-D BUILD_opencv_highgui=OFF				\
		-D BUILD_opencv_python3=ON \
		-D BUILD_opencv_calib3d=OFF \
		-D BUILD_opencv_cudacodec=OFF \
		-D BUILD_opencv_dnn=OFF \
		-D BUILD_opencv_flann=OFF \
		-D BUILD_opencv_gapi=OFF \
		-D BUILD_opencv_imgproc=OFF \
		-D BUILD_opencv_ml=OFF \
		-D BUILD_opencv_photo=OFF \
		-D BUILD_opencv_sfm=OFF \
		-D BUILD_opencv_video=OFF \
		-D BUILD_opencv_videoio=OFF \
		-D BUILD_opencv_videostab=OFF \
		-D BUILD_opencv_viz=OFF \
		-D PYTHON3_NUMPY_INCLUDE_DIRS="$NUMPY"	\
		-D PYTHON3_EXECUTABLE=/usr/bin/python3.7  \
		-D PYTHON3_INCLUDE_DIR=/usr/include/python3.7m  \
		-D PYTHON3_PACKAGES_PATH=/usr/lib/python3.7/site-packages \
		..
	make -j`cat /proc/cpuinfo | grep MHz | wc -l`
)
cp build/opencv/build/lib/python3/cv2.cpython-37m-x86_64-linux-gnu.so package/cv2/cv2.cpython-37m-x86_64-linux-gnu.so
cp -L build/opencv/build/lib/*.so.4.0 package/cv2
strip --strip-all package/cv2/*
echo '$ORIGIN'
chrpath -r '$ORIGIN' package/cv2/cv2.cpython-37m-x86_64-linux-gnu.so
touch package/cv2/__init__.py
echo "import importlib" >> package/cv2/__init__.py
echo "globals().update(importlib.import_module('cv2.cv2').__dict__)" >> package/cv2/__init__.py

