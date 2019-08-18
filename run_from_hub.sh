#!/bin/sh

docker run \
       -p 6080:80 \
       -it \
       --env RESOLUTION=1280x720 \
       sousou1/fpt-simulator:latest
