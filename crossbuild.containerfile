ARG image=debian:testing
ARG native_arch=amd64
ARG target_arch=arm64v8

FROM $native_arch/$image AS mini_sudo
WORKDIR /tmp
COPY mini_sudo.c ./
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
       --no-install-recommends -y gcc libc-dev \
    && gcc -Wall -Werror -static -o sudo mini_sudo.c \
    && install -m 6755 sudo /usr/local/bin/sudo

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

FROM $target_arch/$image
WORKDIR /tmp
COPY debian-src.sources local-pkgs.list /etc/apt/sources.list.d/
COPY local-pkgs /etc/apt/preferences.d/
COPY pkgs ./
RUN mkdir /pkgs \
    && touch /pkgs/Packages \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
       --no-install-recommends -y build-essential ca-certificates debhelper \
       devscripts git yq $(awk '{ print $1 }' pkgs) \
    && apt-mark hold $(awk '{ print $1 }' pkgs)
COPY --from=native /native /native
COPY setup_native ./
RUN [ "/native/bash", "-c", "PATH=/native:$PATH ./setup_native import $(awk '{ print $1 }' pkgs)" ]
RUN gcc --print-search-dir \
    && echo 'int main() { return 0; }' > main.c \
    && gcc -o main main.c \
    && ./main \
    && find /tmp -mindepth 1 -delete
COPY build_source /usr/local/bin/
COPY build_indep /usr/local/bin/
COPY build_archdep /usr/local/bin/
COPY build /usr/local/bin/
COPY --from=mini_sudo /usr/local/bin/sudo /usr/local/bin/sudo
RUN groupadd dev && useradd -m -g dev dev
USER dev
RUN mkdir /home/dev/work
WORKDIR /home/dev/work
