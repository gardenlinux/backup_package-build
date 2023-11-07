# Use build arguments to specify the base image and architecture
ARG image=debian:testing
ARG arch=amd64

# Stage 1: Build and install mini_sudo
FROM $arch/$image AS mini_sudo
WORKDIR /tmp
COPY misc/mini_sudo.c ./
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
       --no-install-recommends -y gcc libc-dev \
    && gcc -Wall -Werror -static -o sudo mini_sudo.c \
    && install -m 6755 sudo /usr/local/bin/sudo 

# Stage 2: Final image
FROM $arch/$image
WORKDIR /tmp

# Copy repository configration files for apt 
COPY container/apt/ /etc/apt/

# Create a directory for local packages and touch the Packages file
RUN mkdir /pkgs && touch /pkgs/Packages

# Copy the package list file
COPY container/conf/pkgs ./

# Install packages from pkgs list and mark them as held, test gcc and cleanup
RUN find /etc/apt/ && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
       --no-install-recommends -y build-essential ca-certificates \
       debhelper devscripts git sudo yq $(awk '{ print $1 }' pkgs) \
    && apt-mark hold $(awk '{ print $1 }' pkgs) \
    && gcc --print-search-dir && echo 'int main() { return 0; }' > main.c \
    && gcc -o main main.c \
    && ./main \
    && find /tmp -mindepth 1 -delete

# Copy the build scripts from bin/ into /usr/local/bin
COPY container/bin/ /usr/local/bin

# Copy mini_sudo from stage 1
COPY --from=mini_sudo /usr/local/bin/sudo /usr/local/bin/sudo

# Create user dev and set the working directory for the user
RUN groupadd dev && useradd -m -g dev dev
USER dev
RUN mkdir /home/dev/work
WORKDIR /home/dev/work
