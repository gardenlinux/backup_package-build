# Project Name: gardenlinux/package-build

## Description
This project is part of the gardenlinux organization on GitHub and focuses on package building for GardenLinux system.

It contains:
- `container/`: This folder contains container-related files that define images and configurations.
  - `*.containerfile`: These files define container images.
  - `apt/`: This folder contains apt configuration files.
  - `bin/`: This folder contains executable scripts installs into the container.
  - `conf/`: This folder contains containers configurations on installed packages list and native container setup.
- `misc/`: This folder contains miscellaneous files related to the project.
- `scripts/`: This folder contains scripts for it's github actions workflow.

## Local Dev

### Build container

on amd64:
```
podman build --build-arg arch=amd64 -f container/build.containerfile -t build:amd64 .
```

on arm64:
```
podman build --build-arg arch=arm64v8 -f container/build.containerfile -t build:arm64v8 .
```

### Build a package

inside the package repo:
```
podman run --rm -v $PWD:/input -v $PWD/.build:/output build:amd64 build
```

alternatively the pre-build containers from ghcr can be used: https://github.com/gardenlinux/package-build/pkgs/container/package-build
