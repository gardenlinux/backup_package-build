ARG image=debian:testing
ARG native_arch=amd64
ARG target_arch=arm64v8

FROM $native_arch/$image AS mini_sudo
WORKDIR /tmp
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y gcc libc-dev
COPY mini_sudo.c ./
RUN gcc -Wall -Werror -static -o sudo mini_sudo.c \
    && install -m 6755 sudo /usr/local/bin/sudo

FROM $native_arch/$image AS native
ARG gnu_arch=aarch64
WORKDIR /tmp
COPY pkg setup_native ./
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y bbe patchelf $(sed 's/\$arch/'"$gnu_arch"'/' pkgs | awk '{ print $NF }') \
    && ./setup_native export $(sed 's/\$arch/'"$gnu_arch"'/' pkgs | awk '{ print $NF }')

FROM $target_arch/$image
WORKDIR /tmp
COPY bin /usr/local/bin
RUN mkdir /pkgs \
    && touch /pkgs/Packages \
    && echo 'deb [trusted=yes] file:/pkgs /' >> /etc/apt/sources.list \
    && echo -e 'Package: *\nPin: origin ""\nPin-Priority: 900' > /etc/apt/preferences.d/local-pkgs
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
COPY --from=mini_sudo /usr/local/bin/sudo /usr/local/bin/sudo
RUN groupadd dev && useradd -m -g dev dev
USER dev
RUN mkdir /home/dev/work
WORKDIR /home/dev/work
