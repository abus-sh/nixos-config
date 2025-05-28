#!/bin/sh

# Make sure the right directory is used. If run as root, $SUDO_HOME will point to the right location, not $HOME.
DIR="${SUDO_HOME:-$HOME}"

# Based on https://www.youtube.com/watch?v=Dy3KHMuDNS8
pushd $DIR/.nixos
sudo nixos-rebuild switch -I nixos-config=./system/configuration.nix
popd