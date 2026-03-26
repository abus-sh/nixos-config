# /boot is (Almost) Full

1. Run `nixos-rebuild list-generations` to see all generations.
2. Identify which generations have a different kernel version.
3. Run `sudo nix-env --delete-generations $GENERATION --profile /nix/var/nix/profiles/system` for
each generation with an old kernel.
4. Run `update-system.sh` to make sure the kernel version is up-to-date.
5. Rebuild system.
6. If the rebuild fails, manually (BUT CAREFULLY) delete files from /boot for old kernels.
