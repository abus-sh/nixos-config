#!/bin/sh
# Based on https://www.youtube.com/watch?v=Dy3KHMuDNS8
pushd ~/.nixos
sudo nixos-rebuild switch -I nixos-config=./system/configuration.nix
popd