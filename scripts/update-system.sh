sudo nix-channel --update

pushd ~/.nixos
nix flake update
popd
