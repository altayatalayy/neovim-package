# The build stage
FROM ubuntu:22.04 AS build

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages for building the .deb package
RUN apt-get update && \
    apt-get install -y \
    devscripts \
    build-essential \
    fakeroot \
    lintian \
    dh-make \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /usr/src/neovim

# Download the neovim tar.gz and its checksum file
RUN wget https://github.com/neovim/neovim/releases/download/v0.9.2/nvim-linux64.tar.gz && \
    wget https://github.com/neovim/neovim/releases/download/v0.9.2/nvim-linux64.tar.gz.sha256sum

# Verify the checksum
RUN sha256sum -c nvim-linux64.tar.gz.sha256sum

# Extract the tar.gz file
RUN tar -xf nvim-linux64.tar.gz

# Copy the local package directory to the container
COPY . .

# Build the .deb package
RUN debuild -us -uc

# The test stage
FROM ubuntu:22.04 AS test

# Set environment variables to avoid warnings during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory in the container
WORKDIR /usr/src/neovim_test

# Copy the .deb package from the build stage
COPY --from=build /usr/src/*.deb .

# Install the .deb package
RUN dpkg -i *.deb

# Test if neovim can be run
RUN nvim --version

# Rename the .deb file
RUN mv /usr/src/neovim_test/*.deb /usr/src/neovim_test/nvim-linux64.deb

# Set the default command to run when starting the container
CMD ["/bin/bash"]
