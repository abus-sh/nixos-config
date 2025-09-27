#!/bin/sh

usage () {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -h, --help        Display this help message and exit.
  -m, --message     The Git commit message to use.
  -n, --name [NAME] The name of the config that will be used. Defaults to the
                    hostname of the current computer if not specified.
      --no-commit   Skip adding a Git commit.
      --no-spec     Do not switch to a specialisation.
  -s, --spec [SPEC] The name of the specialisation to switch to.
      --upgrade     Passes "--upgrade" to nixos-rebuild.
      --upgrade-all Passes "--upgrade-all" to nixos-rebuild.
EOF
    exit ${1:-0}
}

# Function to append a flag to the FLAGS variable
append_flag () {
    FLAGS="${FLAGS} ${1}"
}

handle_message() {
    # Guard to prevent multiple cases of --message or --no-commit
    if [ -n "$COMMIT_SET" ]; then
        echo "Commit message may not be set multiple times."
        usage 1
    fi
    COMMIT_SET=1

    COMMIT_MSG="$1"
}

handle_name() {
    if [ -n "$name" ]; then
        echo "Name may not be set multiple times."
        usage 1
    fi
    NAME="$1"
}

handle_no_commit() {
    # Guard to prevent multiple cases of --message or --no-commit
    if [ -n "$COMMIT_SET" ]; then
        echo "Commit message may not be set multiple times."
        usage 1
    fi
    COMMIT_SET=1

    NO_COMMIT=1
}

handle_no_spec() {
    # Guard to prevent multiple cases of --spec or --no-spec
    if [ -n "$SPEC_SET" ]; then
        echo "Specialisation may not be set multiple times."
        usage 1
    fi
    SPEC_SET=1
}

handle_spec() {
    # Guard to prevent multiple cases of --spec or --no-spec
    if [ -n "$SPEC_SET" ]; then
        echo "Specialisation may not be set multiple times."
        usage 1
    fi
    SPEC_SET=1

    SPEC="$1"
}

handle_upgrade() {
    append_flag "--upgrade"
}

handle_upgrade_all() {
    append_flag "--upgrade-all"
}

# Handle arguments to the script
# Based on https://stackoverflow.com/a/31443098
while [ "$#" -gt 0 ]; do
  case "$1" in
    # Short names
    -h) usage; shift 1;;
    -m) handle_message "$2"; shift 2 2>/dev/null;;
    -n) handle_name "$2"; shift 2 2>/dev/null;;
    -s) handle_spec "$2"; shift 2 2>/dev/null;;

    # Long names
    --help) usage; shift 1;;
    --message) handle_message "$2"; shift 2 2>/dev/null;;
    --name) handle_name "$2"; shift 2 2>/dev/null;;
    --no-commit) handle_no_commit; shift 1;;
    --no-spec) handle_no_spec; shift 1;;
    --spec) handle_spec "$2"; shift 2 2>/dev/null;;
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

# Append the flag with the name
append_flag "--flake ./system#$NAME"

# Detect if neither --spec nor --no-spec have been supplied, set SPEC if so
if [[ -z "$SPEC_SET" ]]; then
    VERSION="$(cat /run/current-system/nixos-version)"

    if [[ "$VERSION" =~ "-" ]]; then
        # Get all but last field (ex. the version info)
        # Based on https://blog.jefferyb.dev/awk-display-all-fields-except-the-last/
        SPEC="$(echo $VERSION | awk 'BEGIN{FS=OFS="-"}{NF--; print}')"
    fi
fi

if [[ -n "$SPEC" ]]; then
    append_flag "-c ${SPEC}"
fi

# Make sure the right directory is used. If run as root, $SUDO_HOME will point to the right location, not $HOME.
DIR="${SUDO_HOME:-$HOME}"

# If a commit should happen, make one happen
if [[ -z "$NO_COMMIT" ]]; then
    git add .

    if [[ -z "$COMMIT_MSG" ]]; then
        if ! git commit -e; then
            echo "Commit failed."
            exit 1
        fi
    else
        git commit -m "$COMMIT_MSG"
    fi
fi

# Based on https://www.youtube.com/watch?v=Dy3KHMuDNS8
pushd $DIR/.nixos
sudo nixos-rebuild switch $FLAGS
popd