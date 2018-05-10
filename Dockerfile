FROM ubuntu:xenial
ARG PYTHON
ARG OPENCV
RUN apt update
RUN apt-get build-dep -y python-opencv
RUN apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libsqlite3-dev
RUN mkdir -p /src

# build python from /src/python in-place, install into /opt/python
ADD Python-${PYTHON}.tar.xz /src
RUN \
	cd /src/Python-${PYTHON} && \
	./configure --prefix=/opt/python/${PYTHON}/ && \
	make && \
	make install
RUN /opt/python/${PYTHON}/bin/pip3 install --upgrade pip

# build opencv from /src/opencv in /tmp/opencv_build, install into /opt/opencv
RUN /opt/python/${PYTHON}/bin/pip3 install numpy
ADD opencv-${OPENCV}.tar.gz /src
RUN \
	mkdir /tmp/opencv_build && \
	cd /tmp/opencv_build && \
	cmake \
	-DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_INSTALL_PREFIX=/opt/opencv \
	-DBUILD_opencv_video=OFF \
	-DBUILD_opencv_videoio=OFF \
	-DBUILD_opencv_java=OFF \
	-DPYTHON3_EXECUTABLE=/opt/python/${PYTHON}/bin/python3 \
	-DPYTHON3_PACKAGES_PATH=$(echo /opt/python/${PYTHON}/lib/python*/site-packages) \
	-DPYTHON3_LIBRARY=$(echo /opt/python/${PYTHON}/lib/python*/config-*-x86_64-linux-gnu/libpython*.so) \
	-DPYTHON3_INCLUDE_DIR=$(echo /opt/python/${PYTHON}/include/python*) \
	-DBUILD_opencv_python3=ON \
	/src/opencv-${OPENCV}
RUN cd /tmp/opencv_build ; make install

# package the built data
RUN \
	/opt/python/${PYTHON}/bin/python3 -c 'import cv2' && \
	cp /opt/python/${PYTHON}/lib/python*/site-packages/cv2.cpython-*-x86_64-linux-gnu.so /opt/opencv/ && \
	cd /opt && tar cvf opencv-${OPENCV}-py${PYTHON}.tar.xz --xz opencv
