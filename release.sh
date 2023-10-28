#!/bin/bash

docker build -f nvim.Dockerfile -t neovim-builder .
docker create --name temp_container_nvim neovim-builder
docker cp temp_container_nvim:/app/nvim-linux64-22.deb ./
docker cp temp_container_nvim:/app/nvim-linux64-20.deb ./
docker cp temp_container_nvim:/app/nvim-linux64-18.deb ./
docker container rm temp_container_nvim

docker build -f tmux.Dockerfile -t tmux-builder .
docker create --name temp_container_tmux tmux-builder
docker cp temp_container_tmux:/app/tmux.deb ./
docker cp temp_container_tmux:/app/tmux10.deb ./
docker container rm temp_container_tmux

TAG_NAME=$(git tag -l --points-at HEAD)

gh auth login --with-token <<< "${GH_TOKEN}"

gh release create $TAG_NAME \
            ./nvim-linux64-22.deb \
            ./nvim-linux64-20.deb \
            ./nvim-linux64-18.deb \
            ./tmux.deb \
            ./tmux10.deb \
            -t $TAG_NAME \
            -n "Release $TAG_NAME"

rm ./nvim-linux64-22.deb \
    ./nvim-linux64-20.deb \
    ./nvim-linux64-18.deb \
    ./tmux.deb \
    ./tmux10.deb \
