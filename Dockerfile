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

RUN apt-get update && apt-get upgrade -y \
    && wget https://raw.githubusercontent.com/ROBOTIS-GIT/robotis_tools/master/install_ros_kinetic.sh && chmod 755 ./install_ros_kinetic.sh && bash ./install_ros_kinetic.sh

RUN apt-get update && apt-get install -q -y \
    ros-kinetic-joy ros-kinetic-teleop-twist-joy ros-kinetic-teleop-twist-keyboard ros-kinetic-laser-proc ros-kinetic-rgbd-launch ros-kinetic-depthimage-to-laserscan ros-kinetic-rosserial-arduino ros-kinetic-rosserial-python ros-kinetic-rosserial-server ros-kinetic-rosserial-client ros-kinetic-rosserial-msgs ros-kinetic-amcl ros-kinetic-map-server ros-kinetic-move-base ros-kinetic-urdf ros-kinetic-xacro ros-kinetic-compressed-image-transport ros-kinetic-rqt-image-view ros-kinetic-gmapping ros-kinetic-navigation ros-kinetic-interactive-markers

# install other ros packages
RUN apt-get update && apt-get install -y \
    ros-kinetic-uvc-camera \
    ros-kinetic-image-* \
    && rm -rf /var/lib/apt/lists/*

# RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc


# download turtlebot3 model
RUN mkdir -p /root/catkin_ws/src/ \
    && cd /root/catkin_ws/src/ \
    && git clone https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git \
    && git clone https://github.com/ROBOTIS-GIT/turtlebot3.git \
    && git clone https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git



COPY gazebo_simulation/turtlebot3_simulations /tmp/turtlebot3_simulations
COPY gazebo_simulation/turtlebot3/turtlebot3_description /tmp/turtlebot3_description
COPY opencv_sample /root/catkin_ws/src/opencv_sample

RUN cp -r /tmp/turtlebot3_simulations/turtlebot3_gazebo/models/road_meshes /root/catkin_ws/src/turtlebot3_simulations/turtlebot3_gazebo/models/ \
    && cp -r  /tmp/turtlebot3_simulations/turtlebot3_gazebo/launch/FPT_C.launch /root/catkin_ws/src/turtlebot3_simulations/turtlebot3_gazebo/launch \
    && cp -r  /tmp/turtlebot3_simulations/turtlebot3_gazebo/worlds/FPT_C.world /root/catkin_ws/src/turtlebot3_simulations/turtlebot3_gazebo/worlds \
    && cp -r  /tmp/turtlebot3_description/urdf/turtlebot3_burger.gazebo.xacro /root/catkin_ws/src/turtlebot3/turtlebot3_description/urdf \
    && cp -r  /tmp/turtlebot3_description/urdf/turtlebot3_burger.urdf.xacro /root/catkin_ws/src/turtlebot3/turtlebot3_description/urdf


RUN su -c "bash -c 'source /opt/ros/kinetic/setup.bash; \
           cd /root/catkin_ws; \
           catkin_make;'"


# Gazebo upgrade
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" >> /etc/apt/sources.list.d/gazebo-stable.list
RUN su -c "bash -c 'wget http://packages.osrfoundation.org/gazebo.key -O - |  apt-key add - '" $USERNAME
RUN apt update
RUN apt upgrade -y

# Create start shell on root Desktop

RUN mkdir /root/Desktop
RUN echo "#!/bin/bash" >> /root/Desktop/simulator.sh \
    && echo "" >> /root/Desktop/simulator.sh \
    && echo "source /opt/ros/kinetic/setup.bash" >> /root/Desktop/simulator.sh \
    && echo "source /root/catkin_ws/devel/setup.bash" >> /root/Desktop/simulator.sh \
    && echo "export TURTLEBOT3_MODEL=burger" >> /root/Desktop/simulator.sh \
    && echo "roslaunch turtlebot3_gazebo FPT_C.launch" >> /root/Desktop/simulator.sh

RUN echo "#!/bin/bash" >> /root/Desktop/teleop.sh \
    && echo "" >> /root/Desktop/teleop.sh \
    && echo "source /opt/ros/kinetic/setup.bash" >> /root/Desktop/teleop.sh \
    && echo "source /root/catkin_ws/devel/setup.bash" >> /root/Desktop/teleop.sh \
    && echo "export TURTLEBOT3_MODEL=burger" >> /root/Desktop/teleop.sh \
    && echo "roslaunch turtlebot3_teleop turtlebot3_teleop_key.launch" >> /root/Desktop/teleop.sh

RUN echo "#!/bin/bash" >> /root/Desktop/cv_sample.sh \
    && echo "" >> /root/Desktop/cv_sample.sh \
    && echo "source /opt/ros/kinetic/setup.bash" >> /root/Desktop/cv_sample.sh \
    && echo "source /root/catkin_ws/devel/setup.bash" >> /root/Desktop/cv_sample.sh \
    && echo "rosrun opencv_sample opencv_sample" >> /root/Desktop/cv_sample.sh

RUN chmod +x /root/Desktop/simulator.sh
RUN chmod +x /root/Desktop/teleop.sh


RUN echo "source /opt/ros/kinetic/setup.bash" >> /root/.bashrc
RUN echo "source /root/catkin_ws/devel/setup.bash" >> /root/.bashrc
RUN echo "export TURTLEBOT3_MODEL=burger" >> /root/.bashrc