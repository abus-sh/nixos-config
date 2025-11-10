#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3
import argparse
import os
import subprocess
import sys

def git_commit(args):
    if args.no_commit:
        return

    # Add all unstagged files
    subprocess.run(["git", "add", "."])

    # If there aren't any changes, don't commit anything
    result = subprocess.run(["git", "diff", "--name-only"], capture_output=True)
    if result.stdout.strip() == b"":
        return

    # Use provided commit message or prompt for one
    if args.message:
        result = subprocess.run(["git", "commit", "-m", args.message])
    else:
        result = subprocess.run(["git", "commit", "-e"])

    if result.returncode != 0:
        print("Commit failed.")
        sys.exit(result.returncode)
    
    subprocess.run(["git", "push"])

def system_deploy(args):
    # Build nixos-rebuild command
    rebuild_args = ["sudo", "nixos-rebuild", "switch"]

    if args.spec is not None:
        rebuild_args += ["-c", args.spec]

    if args.upgrade:
        rebuild_args += ["--upgrade"]
    
    if args.upgrade_all:
        rebuild_args += ["--upgrade-all"]
    
    rebuild_args += ["--flake", f".#{args.name or ''}"]

    subprocess.run(rebuild_args)

def remote_deploy(args):
    # Build deploy-rs command
    deploy_args = ["nix", "run", "github:serokell/deploy-rs"]

    deploy_args += [f".#{args.node or ''}"]

    subprocess.run(deploy_args)

def get_arg_parser():
    parser = argparse.ArgumentParser(
        prog="apply-system.py",
    )

    # Disallow providing a commit message when not committing
    commit_message_group = parser.add_mutually_exclusive_group()
    commit_message_group.add_argument("-m", "--message", metavar="MSG", help="the commit message to use")
    commit_message_group.add_argument("--no-commit", action="store_true", help="Skip committing changes")

    subparsers = parser.add_subparsers(required=True, help="deployment target")

    # Handle deploying to the local system
    parser_system = subparsers.add_parser("system", help="deploy to the current system")
    parser_system.set_defaults(func=system_deploy)
    parser_system.add_argument("-n", "--name", help="the name of the flake to use")

    # Disallow providing a spec and no-spec
    spec_group = parser_system.add_mutually_exclusive_group()
    spec_group.add_argument("--no-spec", action="store_true", help="do not switch to a specialisation")
    spec_group.add_argument("-s", "--spec", help="the name of the specialisation to switch to")

    # Disallow providing upgrade and upgrade-all
    upgrade_group = parser_system.add_mutually_exclusive_group()
    upgrade_group.add_argument("--upgrade", action="store_true", help="passes '--upgrade' to nixos-rebuild")
    upgrade_group.add_argument("--upgrade-all", action="store_true", help="passes '--upgrade-all' to nixos-rebuild")

    # Handle deploying to remote nodes
    parser_remote = subparsers.add_parser("remote", help="deploy to a remote node")
    parser_remote.set_defaults(func=remote_deploy)

    # Disallow providing a node and all
    node_group = parser_remote.add_mutually_exclusive_group()
    node_group.add_argument("--all", help="deploy to all nodes")
    node_group.add_argument("node", nargs="?", default=None, help="the node to deploy to")

    return parser

def main():
    args = get_arg_parser().parse_args()

    # Move into the correct directory for this script
    # Try SUDO_HOME in case we're root, otherwise use HOME
    base_dir = os.environ.get("SUDO_HOME", os.environ.get("HOME", "/home/abus"))
    os.chdir(os.path.join(base_dir, ".nixos"))

    # Handle Git commits
    git_commit(args)

    # Handle the specific subcommand
    args.func(args)

if __name__ == "__main__":
    main()
