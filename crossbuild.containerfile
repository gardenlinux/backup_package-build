# Use build arguments to specify the base image and architecture
ARG image=debian:testing
ARG native_arch=amd64
ARG target_arch=arm64v8

# Stage 1: Build and install mini_sudo
FROM $native_arch/$image AS mini_sudo
WORKDIR /tmp
COPY mini_sudo.c ./
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
       --no-install-recommends -y gcc libc-dev \
    && gcc -Wall -Werror -static -o sudo mini_sudo.c \
    && install -m 6755 sudo /usr/local/bin/sudo

# Stage 2: Build setup_native 
FROM $native_arch/$image AS native
ARG gnu_arch=aarch64
WORKDIR /tmp
COPY pkgs setup_native ./
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
       --no-install-recommends -y bbe patchelf \
       $(sed 's/\$arch/'"$gnu_arch"'/' pkgs | awk '{ print $NF }') \
    && ./setup_native export $(sed 's/\$arch/'"$gnu_arch"'/' pkgs \
       | awk '{ print $NF }')

# Stage 3: Final image
FROM $target_arch/$image
WORKDIR /tmp

# Copy repository configration files for apt
COPY debian-src.sources local-pkgs.list /etc/apt/sources.list.d/
COPY local-pkgs /etc/apt/preferences.d/

# Install packages from pkgs list and mark them as held, test gcc
COPY pkgs ./
RUN mkdir /pkgs \
    && touch /pkgs/Packages \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
       --no-install-recommends -y build-essential ca-certificates debhelper \
       devscripts git yq $(awk '{ print $1 }' pkgs) \
    && apt-mark hold $(awk '{ print $1 }' pkgs) \
    && gcc --print-search-dir \
    && echo 'int main() { return 0; }' > main.c \
    && gcc -o main main.c \
    && ./main

# Copy the native build artifacts from the previous stage
COPY --from=native /native /native

# Copy setup_native script and execute it
COPY setup_native ./
RUN [ "/native/bash", "-c", "PATH=/native:$PATH ./setup_native import $(awk '{ print $1 }' pkgs)" ]

# Clean up /tmp
RUN find /tmp -mindepth 1 -delete

# Copy the build scripts to /usr/local/bin
COPY build_source build_indep build_archdep build /usr/local/bin/

# Copy mini_sudo from stage 1
COPY --from=mini_sudo /usr/local/bin/sudo /usr/local/bin/sudo

# Create user dev and set the working directory for the user
RUN groupadd dev && useradd -m -g dev dev
USER dev
RUN mkdir /home/dev/work
WORKDIR /home/dev/work
