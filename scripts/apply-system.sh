#!/bin/sh

# Function to append a flag to the FLAGS variable
append_flag () {
    FLAGS="${FLAGS} ${1}"
}

# Append flag for the location of the system configuration
append_flag "-I nixos-config=./system/configuration.nix"

# Conditionally append flag to keep the current specialisation
VERSION="$(cat /run/current-system/nixos-version)"
if [[ "$VERSION" =~ "-" ]]; then
    # Get all but last field (ex. the version info)
    # Based on https://blog.jefferyb.dev/awk-display-all-fields-except-the-last/
    SPEC="$(echo $VERSION | awk 'BEGIN{FS=OFS="-"}{NF--; print}')"

    append_flag "-c ${SPEC}"
fi

# Make sure the right directory is used. If run as root, $SUDO_HOME will point to the right location, not $HOME.
DIR="${SUDO_HOME:-$HOME}"

# Based on https://www.youtube.com/watch?v=Dy3KHMuDNS8
pushd $DIR/.nixos
sudo nixos-rebuild switch $FLAGS
popd