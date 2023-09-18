# Build stage with Ubuntu 18.04
FROM ubuntu:18.04 as build

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
    wget && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /usr/src/neovim

# Download the Neovim source tarball and extract it
RUN wget https://github.com/neovim/neovim/archive/refs/tags/v0.9.2.tar.gz
RUN tar -xf v0.9.2.tar.gz --strip-components=1

# Build Neovim from source
RUN make CMAKE_BUILD_TYPE=RelWithDebInfo -j$(nproc)
WORKDIR /usr/src/neovim/build
# Generate the .deb package using CPack
RUN cpack -G DEB

# The test stage with Ubuntu 18.04
FROM ubuntu:18.04 AS test

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory in the container
WORKDIR /usr/src/neovim_test

# Here we will copy the .deb file created in the build stage which isn't available yet.
COPY --from=build /usr/src/neovim/build/*.deb .

# Installing and testing the .deb package installation will be added here once debian/ files are ready and .deb package is created.
RUN dpkg -i *.deb
RUN nvim --version

# Set the default command to run when starting the container
CMD ["/bin/bash"]

