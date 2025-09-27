#!/bin/sh

usage () {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -h, --help        Display this help message and exit.
  -n, --name [NAME] The name of the config that will be used. Defaults to the
                    hostname of the current computer if not specified.
      --upgrade     Passes "--upgrade" to nixos-rebuild.
      --upgrade-all Passes "--upgrade-all" to nixos-rebuild.
EOF
    exit ${1:-0}
}

# Function to append a flag to the FLAGS variable
append_flag () {
    FLAGS="${FLAGS} ${1}"
}

handle_name() {
    if [ -n "$name" ]; then
        echo "Name may not be set multiple times."
        usage 1
    fi
    name="$1"
    echo "TODO: figure out flag to pass to use the given hostname"
}

handle_upgrade() {
    append_flag "--upgrade"
}

handle_upgrade_all() {
    append_flag "--upgrade-all"
}

# Append flag for the location of the system configuration
append_flag "-I nixos-config=./system/configuration.nix"

# Handle arguments to the script
# Based on https://stackoverflow.com/a/31443098
while [ "$#" -gt 0 ]; do
  case "$1" in
    # Short names
    -h) usage; shift 1;;
    -n) handle_name "$2"; shift 2 2>/dev/null;;

    # Long names
    --help) usage; shift 1;;
    --name) handle_name "$2"; shift 2 2>/dev/null;;
    --upgrade) handle_upgrade; shift 1;;
    --upgrade-all) handle_upgrade_all; shift 1;;
    
    #-*) echo "Unknown option: $1" >&2; usage 1;;
    #*) handle_argument "$1"; shift 1;;
    *) echo "Invalid argument: $1" >&2; usage 1;;
  esac
  if [ $? -ne 0 ]; then
    usage 1
  fi
done

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