# ------------------------------------------------------------
# ROS 2 Jazzy + Gazebo Harmonic Development Image
# ------------------------------------------------------------
FROM osrf/ros:jazzy-desktop-full

LABEL description="Generic ROS2 Jazzy + Gazebo development container"

# Avoid interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------
# Install useful tools and Gazebo/ROS integrations
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    # ROS <-> Gazebo bridge
    ros-jazzy-ros-gz \
    # Turtlebot (optional but commonly used)
    ros-jazzy-turtlebot3 \
    ros-jazzy-turtlebot3-msgs \
    ros-jazzy-turtlebot3-simulations \
    # Build tools
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    git \
    # GUI / OpenGL utilities
    mesa-utils \
    libgl1 \
    libgl1-mesa-dri \
    libglu1-mesa \
    x11-apps \
    # Quality of life
    nano \
    vim \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Initialize rosdep (safe even if already initialized)
# ------------------------------------------------------------
RUN rosdep init || true && rosdep update

# ------------------------------------------------------------
# Create a default workspace (will be mounted over by compose)
# ------------------------------------------------------------
ENV ROS_WS=/home/ros2_ws
RUN mkdir -p $ROS_WS/src
WORKDIR $ROS_WS

# ------------------------------------------------------------
# Environment setup
# ------------------------------------------------------------
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "source /opt/ros/jazzy/setup.bash" >> /etc/bash.bashrc

# Default TurtleBot model (can be overridden at runtime)
ENV TURTLEBOT3_MODEL=waffle

# Better terminal UX
ENV TERM=xterm-256color
RUN echo 'export PS1="\[\e[1;32m\]\u@ros2\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]$ "' >> /root/.bashrc && \
    echo "alias ls='ls --color=auto'" >> /root/.bashrc

# ------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------
CMD ["bash"]
