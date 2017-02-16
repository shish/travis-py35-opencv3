#!/bin/sh
docker build -t test .
docker run -it -v $(pwd):/home/output test cp /home/travis/opencv.tar.xz /home/output/opencv_bin.tar.xz
