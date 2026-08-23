# /boot is (Almost) Full

1. Run `nixos-rebuild list-generations` to see all generations.
2. Identify which generations have a different kernel version.
3. Run `sudo nix-env --delete-generations $GENERATION --profile /nix/var/nix/profiles/system` for
each generation with an old kernel.
4. Run `update-system.sh` to make sure the kernel version is up-to-date.
5. Rebuild system.
6. If the rebuild fails, manually (BUT CAREFULLY) delete files from /boot for old kernels.

# Taskbar Disappears

1. Run `kill $(pgrep plasmashell)` to kill the current `plasmashell`.
2. Run `plasmashell &` to restart it.

# Debugging Nix Issues

Based on https://discourse.nixos.org/t/how-to-use-builtins-break-effectively/23115

1. Optionally, insert `builtins.break` into expressions (ex.
`foobar = ((_: builtins.break _) <expr>)`).
2. Run `nix flake check . --debugger --no-build` for NixOS issues and `nix build .# --debugger` for
normal flake issues.

# Allow Unfree VS Code Extensions

Use the `resetLicense` function, based on
[this page](https://github.com/nix-community/nix-vscode-extensions#unfree-extensions).
