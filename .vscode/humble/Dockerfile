# DUA environment image.
#
# Roberto Masocco <robmasocco@gmail.com>
# Intelligent Systems Lab <isl.torvergata@gmail.com>
#
# April 5, 2023

# ARM64v8:
FROM arm64v8/ros:humble-ros-base-jammy
# x86_64:
# FROM osrf/ros:humble-desktop-full-jammy

# Change this if you encounter problems with the default user
ARG USER_UID=1000

ENV DEBIAN_FRONTEND=noninteractive

# 删除 docker-clean 文件，避免它影响 apt 补全
RUN rm -f /etc/apt/apt.conf.d/docker-clean

# Install desktop and VNC server and required utilities
# Note: omit pm-utils and xfce4-power-manager to avoid repeated
# attempts to read /sys/power/state inside containers (not present
# in many container runtimes). The power manager isn't useful in
# most containerized dev environments.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    curl gnupg2 lsb-release \
    xfce4 xfce4-terminal \
    tigervnc-standalone-server tigervnc-common tigervnc-tools \
    dbus-x11 x11-xserver-utils xauth x11-apps xterm \
    libnotify-bin ros-humble-desktop-full ros-humble-rmw-cyclonedds-cpp bash-completion
    # && \
  # rm -rf /var/lib/apt/lists/*
# IMAGE SETUP END #

# Install new packages here if you need to rebuild the image for saving time
RUN apt-get install -y --no-install-recommends gdb ros-humble-ruckig net-tools ros-humble-grid-map-ros
RUN apt-get install -y --no-install-recommends ros-humble-nav2-costmap-2d ros-humble-grid-map-costmap-2d ros-humble-nav2-smac-planner
RUN apt-get install -y --no-install-recommends ros-humble-geodesy ros-humble-nav2-map-server ros-humble-nav2-lifecycle-manager
RUN apt-get install -y --no-install-recommends ccache ninja-build

# Create a user with Bash as shell and set password (NOTE: plain text password is for dev convenience only)
# 修复: 构建失败因为 group 'internal' 不存在。先确保需要的自定义组存在，再创建用户。
# 说明:
# - 去掉 -r，使用普通用户 (UID=1000)；-r 用于系统账号，与 UID=1000 不匹配。
# - 标准 bash 路径为 /bin/bash。
# - set -eux 方便后续排错。
RUN set -eux; \
  for grp in internal; do \
    if ! getent group "${grp}" > /dev/null; then \
      groupadd -r "${grp}"; \
    fi; \
  done; \
  useradd -m -s /bin/bash -u "${USER_UID}" -G adm,dialout,internal,plugdev,sudo,tty,video lee && \
  echo "lee:lee" | chpasswd
ENV HOME=/home/lee

# Create workspace directory: host workspaces will be mounted here
RUN mkdir ${HOME}/workspace && \
    chown lee:lee ${HOME}/workspace

# (Optional) Bash history file will be auto-created; no manual directory needed

# Create SSH directory for user
RUN mkdir ${HOME}/.ssh

# Create VNC start script and default xstartup (owned by lee)
RUN cat > /usr/local/bin/start_vnc.sh <<'EOF' && chmod +x /usr/local/bin/start_vnc.sh
#!/usr/bin/env bash

# Minimal VNC launcher for user lee
export HOME=/home/lee
export DISPLAY=:1

mkdir -p "$HOME/.vnc"

# Prepare X authority to avoid xauth warnings
touch "$HOME/.Xauthority" && chmod 600 "$HOME/.Xauthority"
export XAUTHORITY="$HOME/.Xauthority"

# Create VNC password once (non-interactive)
if [ ! -f "$HOME/.vnc/passwd" ]; then
    printf '%s\n' 'lee' | vncpasswd -f > "$HOME/.vnc/passwd" || { echo 'failed to create vnc password'; exit 1; }
  chmod 600 "$HOME/.vnc/passwd"
fi

# Minimal xstartup for XFCE
cat > "$HOME/.vnc/xstartup" <<'XEOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
XEOF
chmod +x "$HOME/.vnc/xstartup"

# Start VNC server on :1
vncserver :1 -geometry 2560x1440 -depth 24 -localhost=0 || { echo 'vncserver failed'; exit 1; }

# Keep container alive by following logs
tail -F "$HOME/.vnc/"*.log || true
EOF

RUN chown -R lee:lee /usr/local/bin/start_vnc.sh /home/lee/.vnc || true

# Switch to internal user
USER lee
WORKDIR ${HOME}

# Copy user configuration files
COPY --chown=lee:lee ./bashrc ./.bashrc
COPY --chown=lee:lee ./colcon-defaults.yaml /home/lee/.colcon/defaults.yaml
COPY --chown=lee:lee ./ros2.sh ./.ros2.sh

# Zsh configuration removed (container now uses Bash by default)

ENV DEBIAN_FRONTEND=dialog

# By default, start a basic shell
CMD ["bash"]
