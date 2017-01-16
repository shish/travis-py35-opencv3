FROM quay.io/travisci/travis-python

# python
ARG PYTHON=3.5.2

RUN \
	mkdir /home/travis/python && \
	cd /home/travis/python && \
	wget https://www.python.org/ftp/python/${PYTHON}/Python-${PYTHON}.tar.xz && \
	tar xf Python-${PYTHON}.tar.xz && \
	rm Python-${PYTHON}.tar.xz
RUN \
	cd /home/travis/python/Python-${PYTHON} && \
	./configure --prefix=/opt/python/${PYTHON}/ && \
	make && \
	make install
USER travis
RUN \
	/opt/python/${PYTHON}/bin/pyvenv /home/travis/virtualenv/python${PYTHON} && \
	ln -s /home/travis/virtualenv/python${PYTHON} /home/travis/virtualenv/python3.5 && \
	/home/travis/virtualenv/python${PYTHON}/bin/pip install numpy

# cmake
USER root
RUN \
	wget --no-check-certificate https://cmake.org/files/v3.7/cmake-3.7.2.tar.gz && \
	tar xzf cmake-3.7.2.tar.gz && \
	cd cmake-3.7.2 && \
	./configure --prefix=/opt/cmake && \
	make && \
	make install

# opencv deps
USER root
RUN apt-get update
RUN apt-get build-dep -y python-opencv
RUN /opt/python/${PYTHON}/bin/pip3 install numpy

# opencv
RUN mkdir /opencv_build

COPY opencv.tgz /
RUN tar xzf /opencv.tgz ; cd /opencv ; git checkout 3.2.0
#COPY opencv_contrib.tgz /
#RUN tar xzf /opencv_contrib.tgz ; cd /opencv_contrib ; git checkout 3.2.0

RUN \
	cd /opencv_build && \
	/opt/cmake/bin/cmake \
	-DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_INSTALL_PREFIX=/home/travis/opencv \
	-DBUILD_opencv_video=OFF \
	-DBUILD_opencv_videoio=OFF \
	-DBUILD_opencv_java=OFF \
	-DPYTHON3_EXECUTABLE=/opt/python/${PYTHON}/bin/python3 \
	-DPYTHON3_PACKAGES_PATH=/opt/python/${PYTHON}/lib/python3.5/site-packages \
	-DPYTHON3_LIBRARY=/opt/python/${PYTHON}/lib/python3.5/config-3.5m-x86_64-linux-gnu/libpython3.5.so \
	-DPYTHON3_INCLUDE_DIR=/opt/python/${PYTHON}/include/python3.5m \
	-DBUILD_opencv_python3=ON \
	/opencv
RUN cd /opencv_build ; make install
RUN chown -R travis:travis /home/travis/opencv

USER travis
RUN \
	/opt/python/${PYTHON}/bin/python3 -c 'import cv2' && \
	cp /opt/python/${PYTHON}/lib/python3.5/site-packages/cv2.cpython-35m-x86_64-linux-gnu.so /home/travis/opencv/ && \
	cd /home/travis && \
	tar cvf opencv.tar.xz --xz opencv

USER root
