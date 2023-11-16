# Gardenlinux build-package workflows

This repository contains the Gardenlinux workflows for building and deploying containers and provide a resuable workflow for other packages to build and depolying.

## Workflows

The following workflows are defined in this repository:

- `build_container.yml`: This workflow builds container images based on the provided .containererfile and pushes it to a container registry.
- `build_pkg.yml`: This is reusable workflow builds a package based on the provided input configurations and pushes it to a package repository.

## Workflow Details

### Build Container

The `build_container.yml` workflow is responsible for building container images and pushing it to a container registry.

#### Workflow Configuration

The `container/` folder in this project contains all it's configurations. The `build_container.yml` workflow is triggered on every push to the repository. 

#### Job Details

The `build` job within the `build_container.yml` workflow performs the following steps:
- Checks out the repository.
- Sets up the binfmt using a privileged Podman container.
- Builds the container images based on the provided containerfiles, considering the `host` and `target` matrix values that builds amd64:amd64, arm64v8:amd64, amd64:arm64v8 and arm64v8:arm64v8 images.
- Publishes the built container images to the container registry.

### Build Package

The `build_pkg.yml` workflow is a reusable workflow that can be called by other packages. It builds a package based on the provided input configurations and pushes it to a package repository.

#### Workflow Configuration

The `build_pkg.yml` workflow can be triggered by calling it with specific input parameters.

Input Parameters available in `build_pkg.yml`:
- `repository` (string, default: ${{ github.repository }}): The repository to build the package from.
- `ref` (string, default: ${{ github.sha }}): The ref (commit or branch) to build the package from.
- `build_container` (string, default: ghcr.io/gardenlinux/package-build): The container image used for building the package.
- `dependencies` (string, default: ""): Comma-separated list of repositories and tags to fetch dependencies from.
- `debemail` (string, default: "contact@gardenlinux.io"): The Debian package maintainer email.
- `debfullname` (string, default: "Garden Linux Builder"): The Debian package maintainer full name.
- `distribution` (string, default: "gardenlinux"): The target distribution for the package.
- `message` (string, default: "Rebuild for Garden Linux."): The changelog entry message for the package build.
- `build_options` (string): Additional build options for the package.
- `source_name` (string, default: "${{ github.workflow }}"): The name of the source package.
- `source_version` (string): The version of the source package.
- `version_suffix` (string, default: "gl0"): The version suffix for the package.

#### Job Details

The `build_pkg.yml` workflow consists of the following jobs:
- `source`: This job retrieves the source package, sets up the build environment, and builds the source package.
- `packages`: This job builds the binary packages for the specified architecture.
- `publish`: This job publishes the drafted release.
- `cleanup`: This job deletes the drafted release in case of failure.

#### Usage

To use the `build_pkg.yml` workflow defined in this repository, follow these steps:

1. Create a new workflow file (e.g., `build.yaml`) in the `.github/workflows/` folder of your package-project.
2. In the new workflow file, include the following content, eg: htop:

```
   name: project
   on: push
   jobs:
     htop:
       uses: gardenlinux/package-build/.github/workflows/build_pkg.yaml@branchname
```
Replace `project` to other package name of your package-project. Replace `branchname` with the specific branch or tag of the build_pkg.yaml workflow you want to use. The default is `main` branch.

3. Call the gardenlinux/package-build/.github/workflows/build_pkg.yml@branchname workflow with the specific input parameters under `with:` specific to your project. such as `debemail`, `debfullname`, `distribution`, `message` and others mentioned in the Workflow Configuration section. The default values will be use if wihout provide any input parameters.
```
       uses: gardenlinux/package-build/.github/workflows/build_pkg.yaml@branchname
       with:
         debemail: your@address
         debfullname: "Your Name"
```
4. Commit and push the new workflow file to your project's repository.
5. The `build_pkg.yml` workflow will be triggered based on the provided inputs.

Note: Make sure to adjust and use the matches branch name on your package-project in the uses field to match the desired branchname of the build_pkg.yaml@branchname workflow.

## Contributing

Contributions to this repository are welcome. If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.
