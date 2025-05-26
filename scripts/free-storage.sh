#!/bin/sh

# TODO: prune old system builds here

sudo nix-store --gc
sudo nix-store --optimise