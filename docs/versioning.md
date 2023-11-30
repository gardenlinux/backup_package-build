# Versioning

This chapter describes how the versioning of Garden Linux packages work that have not been mirrored by other sources. Thereby, there are three types of version schemas used:

- [Commit Hash Version](#commit-hash-version)
- [First Upstream Version](#first-upstream-version)
- [Git Tag Version](#git-tag-version)

## Commit Hash Version
**Example:** `gardenlinux/3.2.2-2gardenlinux~3618de3e65de043ca91cbf3f112eaf353a2c9c68`
**Published:** `false`

Whenever there is a build triggered in a given package repo that is not based on a provided Git Tag, the pipeline tries to evaluate if there was already a released build for the given upstream version of the corresponding package by checking the Git tags of the corresponding package repo. 

If there was already such a build, this versioning schema applies to the package build then.

This way, a developer can test changes to the package repo like providing new patches for it. Once the resulting package fulfills the expectation, a developer could then tag its latest commit, so that the latest version is properly versioned and could be published to Github releases as described in chapter [Git Tag Version](#git-tag-version).

Packages that are using this kind of versioning are only built but not published. In order to access those packages, the corresponding package build (Github Action) must be opened. It contains the source and binary package of the given built package in its artifact section.

## First Upstream Version
**Example:** `gardenlinux/3.2.2-2gardenlinux0`
**Published:** `true`

If the package pipeline is triggered without providing a Git Tag and it turns out that there was not already a released build for the given upstream version, then the pipeline will automatically add a Git Tag and publish the resulting package to the Github releases. Thereby, the pipeline checks the Git tags of the given package repo to determine if such a version has already been released or not.

In order to provide a proper version schema, the pipeline will add the version suffix `gardenlinux0` to such packages. This way, a developer can see that the package was automatically built and updated by the packaging pipeline.

This mechanism allows to automatically update Garden Linux packages whenever there is an update in the corresponding upstream version without requiring a developer to add a Git tag. This reduces the general maintenance efforts because a developer doesn't need to manually tag a package to get the latest upstream version into the Garden Linux releases.

## Git Tag Version
**Example:** `gardenlinux/3.2.2-2gardenlinux1`, `gardenlinux/3.2.2-2gardenlinux2`, `gardenlinux/3.2.2-2gardenlinux3`, ...
**Published:** `true`

If there is already a released built for the given upstream version in the Garden Linux package releases but a developer needs to provide updates to the package itself (e.g. via new patches), the developer can release such an update by tagging the last functional Git commit with the following schema:
* `{UPSTREAM VERSION}gardenlinux{1|2|3|...}`

As long as the developer does not tag such a package, the versioning from chapter [Commit Hash Version](#commit-hash-version) applies to the built package. Such packages are considered to be used for testing only whereas tagged versions are published to the Garden Linux package releases.