FROM dorowu/ubuntu-desktop-lxde-vnc:xenial
MAINTAINER So Tamura <so.tamura@tier4.jp>
RUN sed -i.bak -e "s%http://tw.archive.ubuntu.com/ubuntu/%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive/%g" /etc/apt/sources.list

# Develop
RUN apt-get update && apt-get install -y \
        software-properties-common \
        wget curl git cmake cmake-curses-gui \
        libboost-all-dev \
        libflann-dev \
	libgsl0-dev \
        libgoogle-perftools-dev \
        libeigen3-dev

# RUN apt-get update && apt-get install -y git curl cmake wget

# Intall ROS
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools
# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
RUN apt-get update && apt-get install -y \
    ros-kinetic-desktop-full \
    ros-kinetic-uvc-camera \
    ros-kinetic-image-* \
    && rm -rf /var/lib/apt/lists/*

RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc



# Create start shell on root Desktop

RUN mkdir /root/Desktop
RUN echo "#!/bin/bash" >> /root/Desktop/simulator.sh
RUN echo "" >> /root/Desktop/simulator.sh
RUN echo "source /opt/ros/kinetic/setup.bash" >> /root/Desktop/simulator.sh
RUN echo "roslaunch runtime_manager runtime_manager.launch" >> /root/Desktop/simulator.sh

RUN chmod +x /root/Desktop/simulator.sh
