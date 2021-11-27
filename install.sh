#!/bin/bash

if [ $# -eq 0 ]; then
  echo "usage: ./install.sh <drone | roboter>"
  exit 1
else
  for i in "$@"; do
    case $i in
      drone|roboter)
        ;;
      *)
        echo "unknown arg: $1"
        exit 1
    esac
  done
fi

for i in "$@"; do
  cat .rosinstall-$i >> .rosinstall
done

case $(lsb_release -sc) in
    focal)
        ;;
    *)
        echo "Currently the drone only runs in ubuntu 20.04"
        exit 1
esac

if test -n "$ZSH_VERSION"; then
  CURSHELL=zsh
elif test -n "$BASH_VERSION"; then
  CURSHELL=bash
else
  echo "Currently only Bash and ZSH are supported for an automatic install. Please refer to the manual installation if you use any other shell."
  exit 1
fi

sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo add-apt-repository restricted
sudo apt update

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

sudo aptitude update
sudo aptitude -y install ros-noetic-desktop-full

## Add ros to bashrc
echo "source /opt/ros/noetic/setup.${CURSHELL}" >> ~/.${CURSHELL}rc
source ~/.${CURSHELL}rc

sudo aptitude -y install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential

sudo rosdep init 
rosdep update

sudo aptitude update && sudo aptitude -y install \
    libopencv-dev \
    liblua5.2-dev \
    screen \
    python3-rospkg-modules \
    ros-noetic-navigation \
    ros-noetic-teb-local-planner \
    ros-noetic-mpc-local-planner \
    libarmadillo-dev \
    ros-noetic-nlopt

rosws update

mv pyproject.toml ../../pyproject.toml

cd ../..
poetry install

poetry shell

catkin_make -CMAKE_CXX_STANDARD=14

echo "alias make_drone='catkin_make -C ${PWD} -CMAKE_CXX_STANDARD=14'" >> ~/.${CURSHELL}_aliases
echo "alias workon_solarswarm='cd ${PWD} && poetry shell && source ${PWD}/devel/setup.sh'" >> ~/.${CURSHELL}_aliases

source ~/.${CURSHELL}rc