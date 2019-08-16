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

RUN apt-get update && apt-get upgrade $$ \
    wget https://raw.githubusercontent.com/ROBOTIS-GIT/robotis_tools/master/install_ros_kinetic.sh && chmod 755 ./install_ros_kinetic.sh && bash ./install_ros_kinetic.sh

RUN apt-get update && apt-get install -q -y \
    ros-kinetic-joy ros-kinetic-teleop-twist-joy ros-kinetic-teleop-twist-keyboard ros-kinetic-laser-proc ros-kinetic-rgbd-launch ros-kinetic-depthimage-to-laserscan ros-kinetic-rosserial-arduino ros-kinetic-rosserial-python ros-kinetic-rosserial-server ros-kinetic-rosserial-client ros-kinetic-rosserial-msgs ros-kinetic-amcl ros-kinetic-map-server ros-kinetic-move-base ros-kinetic-urdf ros-kinetic-xacro ros-kinetic-compressed-image-transport ros-kinetic-rqt-image-view ros-kinetic-gmapping ros-kinetic-navigation ros-kinetic-interactive-markers

# install other ros packages
RUN apt-get update && apt-get install -y \
    ros-kinetic-uvc-camera \
    ros-kinetic-image-* \
    && rm -rf /var/lib/apt/lists/*

# RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc


# download turtlebot3 model
RUN cd ~/catkin_ws/src/ \
    && git clone https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git \
    && git clone https://github.com/ROBOTIS-GIT/turtlebot3.git \
    && git clone https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git \
    && cd ~/catkin_ws && catkin_make


# Create start shell on root Desktop

RUN mkdir /root/Desktop
RUN echo "#!/bin/bash" >> /root/Desktop/simulator.sh
RUN echo "" >> /root/Desktop/simulator.sh
RUN echo "source /opt/ros/kinetic/setup.bash" >> /root/Desktop/simulator.sh
RUN echo "roslaunch runtime_manager runtime_manager.launch" >> /root/Desktop/simulator.sh

RUN chmod +x /root/Desktop/simulator.sh

RUN mkdir ~/catkin_ws/src
