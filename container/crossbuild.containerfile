ARG native_arch=amd64
ARG target_arch=arm64v8
ARG version=latest
ARG native_image=ghcr.io/gardenlinux/package-snapshot/$native_arch:$version
ARG target_image=ghcr.io/gardenlinux/package-snapshot/$target_arch:$version

FROM $native_image AS mini_sudo
WORKDIR /tmp
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y gcc libc-dev
COPY mini_sudo.c ./
RUN gcc -Wall -Werror -static -o sudo mini_sudo.c \
    && install -m 6755 sudo /usr/local/bin/sudo

FROM $native_image AS native
ARG gnu_arch=aarch64
WORKDIR /tmp
COPY pkgs setup_native ./
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y bbe patchelf $(sed 's/\$arch/'"$gnu_arch"'/' pkgs | awk '{ print $NF }') \
    && ./setup_native export $(sed 's/\$arch/'"$gnu_arch"'/' pkgs | awk '{ print $NF }')

FROM $target_image
WORKDIR /tmp
COPY bin /usr/local/bin
COPY pkgs setup_native ./
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y build-essential ca-certificates debhelper devscripts git yq $(awk '{ print $1 }' pkgs) \
    && apt-mark hold $(awk '{ print $1 }' pkgs)
COPY --from=native /native /native
RUN [ "/native/bash", "-c", "PATH=/native:$PATH ./setup_native import $(awk '{ print $1 }' pkgs)" ]
RUN gcc --print-search-dir \
    && echo 'int main() { return 0; }' > main.c \
    && gcc -o main main.c \
    && ./main
RUN find /tmp -mindepth 1 -delete
RUN mkdir /pkgs \
    && touch /pkgs/Packages \
    && echo 'deb [trusted=yes] file:/pkgs /' >> /etc/apt/sources.list \
    && printf 'Package: *\nPin: origin ""\nPin-Priority: 900\n' > /etc/apt/preferences.d/local-pkgs
COPY --from=mini_sudo /usr/local/bin/sudo /usr/local/bin/sudo
RUN groupadd dev && useradd -m -g dev dev
USER dev
RUN mkdir /home/dev/work
WORKDIR /home/dev/work
