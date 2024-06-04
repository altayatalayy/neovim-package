# Download stage
FROM alpine as downloader
WORKDIR /tmp
ADD https://github.com/tmux/tmux/releases/download/3.4/tmux-3.4.tar.gz tmux.tar.gz

FROM ubuntu:24.04 AS builder

ARG TMUX_VERSION=3.4
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

COPY --from=downloader /tmp/tmux.tar.gz tmux.tar.gz
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



FROM ubuntu:22.04 AS tester22

COPY --from=builder /tmp/tmux/tmux_*.deb /tmp/tmux.deb

RUN apt-get update && \
    apt-get install -y /tmp/tmux.deb && \
    rm -rf /var/lib/apt/lists/*

# Test the installation
RUN tmux -V


# Final stage: Create a final image containing both .deb packages
FROM ubuntu:18.04 AS final

WORKDIR /app

COPY --from=tester22 /tmp/tmux.deb ./tmux.deb
CMD ["/bin/bash"]
