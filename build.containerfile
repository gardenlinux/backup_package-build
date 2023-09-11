ARG image=debian:testing
ARG arch=amd64

FROM $arch/$image AS mini_sudo
WORKDIR /tmp
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y gcc libc-dev
COPY mini_sudo.c ./
RUN gcc -Wall -Werror -static -o sudo mini_sudo.c
RUN install -m 6755 sudo /usr/local/bin/sudo

FROM $arch/$image
WORKDIR /tmp
COPY debian-src.sources /etc/apt/sources.list.d/
COPY pkgs ./
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y build-essential ca-certificates debhelper devscripts git sudo yq $(awk '{ print $1 }' pkgs)
RUN gcc --print-search-dir && echo 'int main() { return 0; }' > main.c && gcc -o main main.c && ./main
COPY build /usr/local/bin/
RUN find /tmp -mindepth 1 -delete
COPY --from=mini_sudo /usr/local/bin/sudo /usr/local/bin/sudo
RUN groupadd dev && useradd -m -g dev dev
USER dev
WORKDIR /home/dev
