#!/bin/sh

sudo nix-store --gc
sudo nix-store --optimise
sudo nix-collect-garbage --delete-older-than 7d