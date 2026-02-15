# ROS 2 Jazzy + Gazebo (Harmonic) Docker Environment

Docker-based development environment for [ROS 2 Jazzy](https://docs.ros.org/en/jazzy/index.html) with [Gazebo Harmonic](https://gazebosim.org/docs/latest/getstarted/) and [TurtleBot3](https://www.turtlebot.com/turtlebot3/) simulation packages.

## What this provides

- [ROS 2 Jazzy desktop base image](https://hub.docker.com/layers/osrf/ros/jazzy-desktop-full/images/sha256-21d30c68b9d5f032904466a185377dee6fcc71624e62d977c49ca3211e686365) (`osrf/ros:jazzy-desktop-full`)
- Gazebo integration via `ros-jazzy-ros-gz`
- TurtleBot3 simulation packages
- GUI forwarding for tools like Gazebo and RViz2
- Optional GPU support via an override Compose file (`docker-compose.gpu.yml`)

## Repository structure

```text
.
├── Dockerfile
├── docker-compose.gpu.yml
├── docker-compose.yml
├── .env.example
└── src/
```

## Requirements

- Docker 24+
- Docker Compose v2
- Linux host with X11 (for GUI apps)

Optional for GPU mode:

- NVIDIA GPU
- NVIDIA drivers
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Setup

1. Copy the environment file:

   ```bash
   cp .env.example .env
   ```

   This is required: `docker-compose.yml` uses values from `.env` (like `WORKSPACE`).

2. Set `UID` and `GID` in `.env` to match your host user:

   ```bash
   id
   ```

3. Allow local Docker GUI access on the host:

   ```bash
   xhost +local:
   ```

## Build and run

### CPU mode (default)

```bash
docker compose up -d --build
```

### GPU mode (optional)

Use the GPU override compose file:

```bash
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d --build
```

## Enter the container

```bash
docker compose exec ros2 bash
```

Note: the container runs as your host `UID:GID` (non-root) to avoid root-owned files in `src/`, so you won’t be able to run `apt install` from the default shell.

If you prefer `docker exec`, use the container name from `.env`:

```bash
docker exec -it ros2_jazzy bash
```

## Typical ROS workflow

Inside the container:

```bash
colcon build
source install/setup.bash
```

If `ros2` commands are not found in your shell, run:

```bash
source /opt/ros/jazzy/setup.bash
```

## Workspace mapping

The host workspace is mounted into the container:

```text
./src -> /home/ros2_ws
```

Use `src/` on the host for your ROS packages and build in the container.

## Stop the environment

```bash
docker compose down
```

## TurtleBot3 simulation

Inside the container, launch Gazebo with a TurtleBot3:

```bash
ros2 launch turtlebot3_gazebo empty_world.launch.py
```

This starts Gazebo and spawns a TurtleBot3 in the world.

> Always stop simulations with **Ctrl+C** in the terminal.
> Closing the Gazebo window can leave the simulation server running in the background.

## Selecting the TurtleBot3 model (optional)

The simulation uses the model defined by the `TURTLEBOT3_MODEL` environment variable.

By default this repo sets `TURTLEBOT3_MODEL=waffle` in `.env.example`.

To choose a model explicitly for your current shell:

```bash
export TURTLEBOT3_MODEL=burger
```

Other common options:

```bash
export TURTLEBOT3_MODEL=waffle
export TURTLEBOT3_MODEL=waffle_pi
```

Set this before launching the simulation.

## Restarting a clean simulation

If a previous run was not shut down cleanly, stop the container session and relaunch:

```bash
docker compose restart
```

Then re-enter the container and launch again.
