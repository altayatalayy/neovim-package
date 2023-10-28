# Set a build argument for the tmux version

# Stage 1: Build tmux from source and create a .deb package
FROM ubuntu:22.04 AS builder

ARG TMUX_VERSION=3.3a
# Set the DEBIAN_FRONTEND environment variable to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    autoconf \
    automake \
    build-essential \
    bison \
    checkinstall \
    curl \
    libevent-dev \
    libncurses-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/tmux

# Download and extract the specific tmux release source code using the build argument
ADD https://github.com/tmux/tmux/releases/download/3.3a/tmux-3.3a.tar.gz /tmp/tmux/tmux.tar.gz
RUN tar -xf tmux.tar.gz --strip-components=1

# Compile the source code
RUN LDFLAGS="-static" ./configure && \
    make -j $(nproc) && \
    checkinstall \
        --pkgname=tmux \
        --pkgversion="${TMUX_VERSION}" \
        --pkgrelease="1"\
        --backup=no \
        --deldoc=yes \
        --install=no \
        --default

# Stage 2: Test the installation on Ubuntu 22.04
FROM ubuntu:22.04 AS tester22

COPY --from=builder /tmp/tmux/tmux_*.deb /tmp/tmux.deb

RUN apt-get update && \
    apt-get install -y /tmp/tmux.deb && \
    rm -rf /var/lib/apt/lists/*

# Test the installation
RUN tmux -V

# Stage 3: Test the installation on Ubuntu 18.04
FROM ubuntu:18.04 AS tester18

COPY --from=builder /tmp/tmux/tmux_*.deb /tmp/tmux.deb

RUN apt-get update && \
    apt-get install -y /tmp/tmux.deb && \
    rm -rf /var/lib/apt/lists/*

# Test the installation
RUN tmux -V


FROM debian:10 AS builder_deb
ARG TMUX_VERSION=3.3a
# Set the DEBIAN_FRONTEND environment variable to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
# required for checkinstall
RUN echo "deb http://deb.debian.org/debian buster-backports main" > /etc/apt/sources.list.d/unstable.list


RUN apt-get update && \
    apt-get install -y \
    autoconf \
    automake \
    build-essential \
    bison \
    checkinstall \
    curl \
    libevent-dev \
    libncurses-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/tmux

ADD https://github.com/tmux/tmux/releases/download/3.3a/tmux-3.3a.tar.gz /tmp/tmux/tmux.tar.gz
RUN tar -xf tmux.tar.gz --strip-components=1
# Download and extract the specific tmux release source code using the build argument

# Compile the source code
RUN LDFLAGS="-static" ./configure && \
    make -j $(nproc) && \
    checkinstall \
        --pkgname=tmux \
        --pkgversion="${TMUX_VERSION}" \
        --pkgrelease="1"\
        --backup=no \
        --deldoc=yes \
        --install=no \
        --default

# Stage 3: Test the installation on Ubuntu 18.04
FROM debian:10 AS tester10

COPY --from=builder_deb /tmp/tmux/tmux_*.deb /tmp/tmux.deb

RUN apt-get update && \
    apt-get install -y /tmp/tmux.deb && \
    rm -rf /var/lib/apt/lists/*

# Test the installation
RUN tmux -V



# Final stage: Create a final image containing both .deb packages
FROM ubuntu:18.04 AS final

WORKDIR /app

COPY --from=tester22 /tmp/tmux.deb ./tmux.deb
COPY --from=tester18 /tmp/tmux.deb ./tmux18.deb
COPY --from=tester10 /tmp/tmux.deb ./tmux10.deb
CMD ["/bin/bash"]

# The final stage does not need to do anything; 
# we are just using it to copy the files into the final image
