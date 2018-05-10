#!/bin/sh
set -eux

OPENCV=3.4.1
PYTHON=3.6.3

#wget -c https://github.com/opencv/opencv/archive/${OPENCV}.tar.gz -O opencv-${OPENCV}.tar.gz
#wget -c https://www.python.org/ftp/python/${PYTHON}/Python-${PYTHON}.tar.xz

docker build -t test --build-arg PYTHON=${PYTHON} --build-arg OPENCV=${OPENCV} .
docker run -i -v $(pwd):/home/output -t test cp /opt/opencv-${OPENCV}-py${PYTHON}.tar.xz /home/output/
