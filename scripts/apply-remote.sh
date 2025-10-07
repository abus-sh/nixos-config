#!/bin/sh

usage () {
    cat << EOF
Usage: $0 [OPTIONS] [NODE]

Options:
  -h, --help        Display this help message and exit.
      --all         Deploy to all nodes.

Arguments:
  NODE              The name of the node to deploy to.
EOF
    exit ${1:-0}
}

# Function to append a flag to the FLAGS variable
append_flag () {
    FLAGS="${FLAGS} ${1}"
}

handle_all () {
    # Guard to prevent both --all and NODE
    if [ -n "$NODE_SET" ]; then
        echo "--all may not be used with a specific node"
        usage 1
    fi
    NODE_SET=1
    ALL_SET=1
}

handle_node () {
    # Guard to prevent both --all and NODE or multiple nodes
    if [ -n "$NODE_SET" ]; then
        if [ -n "$ALL_SET" ]; then
            echo "--all may not be used with a specific node"
        else
            echo "Multiple nodes are not currently supported"
        fi
        usage 1
    fi
    NODE_SET=1

    append_flag ".#$1"
}

# Handle arguments to the script
# Based on https://stackoverflow.com/a/31443098
while [ "$#" -gt 0 ]; do
  case "$1" in
    # Short names
    -h) usage; shift 1;;

    # Long names
    --all) handle_all; shift 1;;
    --help) usage; shift 1;;
    
    -*) echo "Unknown option: $1" >&2; usage 1;;
    *) handle_node "$1"; shift 1;;
    #*) echo "Invalid argument: $1" >&2; usage 1;;
  esac
  if [ $? -ne 0 ]; then
    usage 1
  fi
done

# Make sure either one or all nodes are selected
if [[ -z "$NODE_SET" ]]; then
    usage 1
fi

nix run github:serokell/deploy-rs $FLAGS