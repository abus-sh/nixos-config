sudo nix-channel --update

pushd ~/.nixos

nix flake update

# Update VS Code extension overlay rev
REV=$(git ls-remote https://github.com/nix-community/nix-vscode-extensions | \
  grep -F "refs/heads/master" | cut -f 1)
if [ "${#REV}" -eq 40 ]; then
  echo \"$REV\" > ./machines/abusmachine/extension-rev.nix
else
  echo "ERROR: unable to update extension-rev.nix"
fi

popd
