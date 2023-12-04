# Project Name: gardenlinux/package-build

## Description
This project is part of the gardenlinux organization on GitHub and focuses on package building for GardenLinux system.

It contains:
- `container/`: This folder contains container-related files that define images and configurations.
  - `*.containerfile`: These files define container images.
  - `apt/`: This folder contains apt configuration files.
  - `bin/`: This folder contains executable scripts installs into the container. 
    > Note: Also available via bind mount in the workflow for enable the possibility of workflow development tests.
  - `conf/`: This folder contains containers configurations on installed packages list and native container setup.
- `docs/`: This directory contains the documentation related to the package pipeline of Garden Linux.
- `misc/`: This folder contains miscellaneous files related to the project.
- `scripts/`: This folder contains scripts for it's github actions workflow.

## Versioning

In the following documentation, you can find more information about how the versioning of Garden Linux packages works:
* [docs/versioning.md](docs/versioning.md)

## Local Development

In the following documentation, you can find more information about how to build Garden Linux packages locally on your machine:
* [docs/local_build.md](docs/local_build.md)

## Workflow

In the following documentation, you can find more information about the Github Action and workflows used to build Garden Linux packages.
* [docs/workflow.md](docs/workflow.md)
