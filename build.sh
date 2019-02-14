#!/bin/bash
# Before run commands below, you must build python3 environment via pyenv
# Setting up build env
sudo yum update -y
sudo yum install -y git cmake gcc-c++ gcc chrpath
mkdir -p lambda-package/cv2 build/numpy

# Build numpy
pip install --install-option="--prefix=$PWD/build/numpy" numpy
cp -rf build/numpy/lib/python3.6/site-packages/numpy lambda-package

# Build OpenCV 3.2
(
	NUMPY=$PWD/lambda-package/numpy/core/include
	cd build
	git clone https://github.com/Itseez/opencv.git
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
		-D PYTHON3_NUMPY_INCLUDE_DIRS="$NUMPY"	\
		-D PYTHON3_EXECUTABLE=/root/.pyenv/versions/3.6.5/bin/python3.6 \
		-D PYTHON3_INCLUDE_DIR=/root/.pyenv/versions/3.6.5/include/python3.6m \
		-D PYTHON3_PACKAGES_PATH=/root/.pyenv/versions/3.6.5/lib/python3.6/site-packages \
		..
	make -j`cat /proc/cpuinfo | grep MHz | wc -l`
)
cp build/opencv/build/lib/python3/cv2.cpython-36m-x86_64-linux-gnu.so lambda-package/cv2/
cp -L build/opencv/build/lib/*.so.4.0 lambda-package/cv2
strip --strip-all lambda-package/cv2/*
chrpath -r '$ORIGIN' lambda-package/cv2/cv2.cpython-36m-x86_64-linux-gnu.so
touch lambda-package/cv2/__init__.py

# Copy template function and zip package
cp template.py lambda-package/lambda_function.py
cd lambda-package
zip -r ../lambda-package.zip *
