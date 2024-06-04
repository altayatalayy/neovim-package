# Download stage
FROM alpine as downloader
WORKDIR /tmp
ADD https://github.com/neovim/neovim/archive/refs/tags/v0.10.0.tar.gz nvim.tar.gz

# Build stage with Ubuntu 22.04
FROM ubuntu:23.10 as builder23
ARG FILE_URL

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages for building the .deb package
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    pkg-config \
    unzip \
    git \
    wget \
    ninja-build \
    libjemalloc-dev && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /usr/src/neovim

# Download the Neovim source tarball and extract it
COPY --from=downloader /tmp/nvim.tar.gz nvim.tar.gz
RUN tar -xf nvim.tar.gz --strip-components=1

# Build Neovim from source with static linking
RUN make CMAKE_BUILD_TYPE=Release -j$(nproc)
WORKDIR /usr/src/neovim/build
# Generate the .deb package using CPack
RUN cpack -G DEB




# Build stage with Ubuntu 22.04
FROM ubuntu:22.04 as builder22
ARG FILE_URL

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages for building the .deb package
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    pkg-config \
    unzip \
    git \
    wget \
    ninja-build \
    libjemalloc-dev && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /usr/src/neovim

# Download the Neovim source tarball and extract it
COPY --from=downloader /tmp/nvim.tar.gz nvim.tar.gz
RUN tar -xf nvim.tar.gz --strip-components=1

# Build Neovim from source with static linking
RUN make CMAKE_BUILD_TYPE=Release -j$(nproc)
WORKDIR /usr/src/neovim/build
# Generate the .deb package using CPack
RUN cpack -G DEB




# Build stage with Ubuntu 22.04
FROM ubuntu:20.04 as builder20
ARG FILE_URL

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages for building the .deb package
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    pkg-config \
    unzip \
    git \
    wget \
    ninja-build \
    libjemalloc-dev && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /usr/src/neovim

# Download the Neovim source tarball and extract it
COPY --from=downloader /tmp/nvim.tar.gz nvim.tar.gz
RUN tar -xf nvim.tar.gz --strip-components=1

# Build Neovim from source with static linking
RUN make CMAKE_BUILD_TYPE=Release -j$(nproc)
WORKDIR /usr/src/neovim/build
# Generate the .deb package using CPack
RUN cpack -G DEB




FROM ubuntu:18.04 as builder18
ARG FILE_URL

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages for building the .deb package
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    pkg-config \
    unzip \
    git \
    wget \
    ninja-build \
    libjemalloc-dev && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /usr/src/neovim

# Download the Neovim source tarball and extract it
COPY --from=downloader /tmp/nvim.tar.gz nvim.tar.gz
RUN tar -xf nvim.tar.gz --strip-components=1

# Build Neovim from source with static linking
RUN make CMAKE_BUILD_TYPE=Release -j$(nproc)
WORKDIR /usr/src/neovim/build
# Generate the .deb package using CPack
RUN cpack -G DEB



# The test stage with Ubuntu 18.04
FROM ubuntu:23.10 AS tester23

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory in the container
WORKDIR /usr/src/neovim_test

# Copy the .deb file created in the build stage
COPY --from=builder23 /usr/src/neovim/build/*.deb .

# Installing and testing the .deb package installation
RUN dpkg -i *.deb
RUN nvim --version



# The test stage with Ubuntu 18.04
FROM ubuntu:22.04 AS tester22

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory in the container
WORKDIR /usr/src/neovim_test

# Copy the .deb file created in the build stage
COPY --from=builder22 /usr/src/neovim/build/*.deb .

# Installing and testing the .deb package installation
RUN dpkg -i *.deb
RUN nvim --version



# The test stage with Ubuntu 18.04
FROM ubuntu:20.04 AS tester20

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory in the container
WORKDIR /usr/src/neovim_test

# Copy the .deb file created in the build stage
COPY --from=builder20 /usr/src/neovim/build/*.deb .

# Installing and testing the .deb package installation
RUN dpkg -i *.deb
RUN nvim --version




# The test stage with Ubuntu 18.04
FROM ubuntu:18.04 AS tester18

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory in the container
WORKDIR /usr/src/neovim_test

# Copy the .deb file created in the build stage
COPY --from=builder18 /usr/src/neovim/build/*.deb .

# Installing and testing the .deb package installation
RUN dpkg -i *.deb
RUN nvim --version



# Final stage: Create a final image containing both .deb packages
FROM ubuntu:18.04 AS final

WORKDIR /app

COPY --from=tester23 /usr/src/neovim_test/nvim-linux64.deb ./nvim-linux64-23.deb
COPY --from=tester22 /usr/src/neovim_test/nvim-linux64.deb ./nvim-linux64-22.deb
COPY --from=tester20 /usr/src/neovim_test/nvim-linux64.deb ./nvim-linux64-20.deb
COPY --from=tester18 /usr/src/neovim_test/nvim-linux64.deb ./nvim-linux64-18.deb
CMD ["/bin/bash"]

# The final stage does not need to do anything; 
# we are just using it to copy the files into the final image
