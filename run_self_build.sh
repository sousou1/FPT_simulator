#!/bin/sh

XAUTH=/home/$USER/.Xauthority

docker run \
       -p 6080:80 \
       -it \
       -u root \
       --env="XAUTHORITY=${XAUTH}" \
       --env RESOLUTION=1280x720 \
       -e VNC_PASSWORD=ubuntu \
       fpt-simulator:latest
