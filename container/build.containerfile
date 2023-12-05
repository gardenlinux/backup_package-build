ARG arch=amd64
ARG version=latest
ARG image=ghcr.io/gardenlinux/package-snapshot/$arch:$version

FROM $image AS mini_sudo
WORKDIR /tmp
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y gcc libc-dev
COPY mini_sudo.c ./
RUN gcc -Wall -Werror -static -o sudo mini_sudo.c \
    && install -m 6755 sudo /usr/local/bin/sudo

FROM $image
WORKDIR /tmp
COPY bin /usr/local/bin
COPY pkgs ./
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y build-essential ca-certificates debhelper devscripts git sudo yq $(awk '{ print $1 }' pkgs) \
    && apt-mark hold $(awk '{ print $1 }' pkgs)
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
