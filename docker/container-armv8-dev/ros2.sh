#!/usr/bin/env bash

# Shell functions and commands for ROS 2 management.
#
# Roberto Masocco <robmasocco@gmail.com>
# Intelligent Systems Lab <isl.torvergata@gmail.com>
#
# April 4, 2023

# shellcheck disable=SC1090

# Initialize ROS 2 environment (Bash only).
ros2init() {
  # Optional: ROS_DOMAIN_ID
  if [[ $# -ne 0 ]]; then
    export ROS_DOMAIN_ID=$1
  fi

  export ROS_VERSION=2
  export ROS_PYTHON_VERSION=3
  export ROS_DISTRO=humble

  # 1) Source ROS 2 base environment (Bash scripts only)
  if [[ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
    # shellcheck disable=SC1090
    source "/opt/ros/${ROS_DISTRO}/setup.bash"
  elif [[ -f "/opt/ros/${ROS_DISTRO}/install/setup.bash" ]]; then
    # shellcheck disable=SC1090
    source "/opt/ros/${ROS_DISTRO}/install/setup.bash"
  elif [[ -f "/opt/ros/${ROS_DISTRO}/setup.sh" ]]; then
    # shellcheck disable=SC1090
    source "/opt/ros/${ROS_DISTRO}/setup.sh"
  else
    echo >&2 "[ros2init] ROS 2 installation not found under /opt/ros/${ROS_DISTRO}."
    return 1
  fi

  # 2) Colcon argcomplete (Bash)
  if [[ -f "/usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" ]]; then
    # shellcheck disable=SC1090
    source "/usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash"
  elif [[ -f "/usr/share/colcon_argcomplete/hook/colcon-argcomplete.sh" ]]; then
    # shellcheck disable=SC1090
    source "/usr/share/colcon_argcomplete/hook/colcon-argcomplete.sh"
  else
    # Fallback to dynamic registration if available
    if command -v register-python-argcomplete3 >/dev/null 2>&1; then
      eval "$(register-python-argcomplete3 colcon)"
    elif command -v register-python-argcomplete >/dev/null 2>&1; then
      eval "$(register-python-argcomplete colcon)"
    fi
  fi

  # 3) Ignition Gazebo / ros_gz (optional overlays)
  if [[ -f "/opt/gazebo/fortress/install/setup.bash" ]]; then
    # shellcheck disable=SC1090
    source "/opt/gazebo/fortress/install/setup.bash"
  fi
  if [[ -f "/opt/ros/ros_gz/install/local_setup.bash" ]]; then
    # shellcheck disable=SC1090
    source "/opt/ros/ros_gz/install/local_setup.bash"
  fi

  # 4) rmw_fastrtps (optional overlay)
  if [[ -f "/opt/ros/rmw_fastrtps/install/local_setup.bash" ]]; then
    # shellcheck disable=SC1090
    source "/opt/ros/rmw_fastrtps/install/local_setup.bash"
  fi

  # 5) Additional DUA utils (optional)
  if [[ -f "/opt/ros/dua-utils/install/local_setup.bash" ]]; then
    # shellcheck disable=SC1090
    source "/opt/ros/dua-utils/install/local_setup.bash"
  fi

  # 6) Workspace overlay (if present)
  if [[ -f "/home/lee/workspace/install/local_setup.bash" ]]; then
    # shellcheck disable=SC1090
    source "/home/lee/workspace/install/local_setup.bash"
  fi
}

# Alias for Gazebo Classic that includes environment variables for HiDPI
alias gazebo='QT_AUTO_SCREEN_SCALE_FACTOR=0 QT_SCREEN_SCALE_FACTORS=[1.0] /usr/bin/gazebo'
