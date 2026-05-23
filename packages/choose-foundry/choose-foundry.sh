#!/bin/sh

SERVICE_NAME="foundry.service"
CONTAINER_ID="380c6f890e49"
INSTANCE=""

usage() {
    echo "Usage:"
    echo "Run one of the following commands (main or lancer) to choose which instance to use."
    echo ""
    echo "choose-foundry main         Turn on the main Foundry instance."
    echo "choose-foundry lancer       Turn on the Lancer Foundry instance."
}

handle_exit() {
    if [ $? -ne 0 ]; then
        echo "[ERROR] Something went wrong. The main Foundry might not be swapped. You should probably copy everything and send it to Abus. "
    fi
}

choose_instance() {
    local SELECTION=""

    while [ "$SELECTION" != "1"  ] && [ "$SELECTION" != "2" ]
    do
        echo "Enter a number for a foundry instance."
        echo "1) Main"
        echo "2) Lancer"
        echo -n "> "
        read SELECTION
    done

    if [ "$SELECTION" == "1" ]; then
        INSTANCE="main"
    else
        INSTANCE="lancer"
    fi
}

turn_on_main() {
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo "[INFO] The main Foundry instance is already running, quitting."
        exit
    else
        # Stop the other instance
        echo "[INFO] Stopping Lancer Foundry..."
        docker stop $CONTAINER_ID
        echo "[INFO] Stopped Lancer Foundry."

        # Start the main instance
        echo "[INFO] Starting main Foundry..."
        systemctl start $SERVICE_NAME
        echo "[INFO] Started main Foundry. It may take 1-2 minutes to come online."
        exit
    fi
}

turn_on_lancer() {
    if [ "$( docker container inspect -f '{{.State.Running}}' $CONTAINER_ID )" = "true" ]; then
        echo "[INFO] The Lancher Foundry instance is already running, quitting."
        exit
    else
        # Stop the other instance
        echo "[INFO] Stopping main Foundry..."
        systemctl stop $SERVICE_NAME
        echo "[INFO] Stopped main Foundry."

        # Start the main instance
        echo "[INFO] Starting Lancer Foundry..."
        docker start $CONTAINER_ID
        echo "[INFO] Started Lancer Foundry. It may take 1-2 minutes to come online."
        exit
    fi
}

set -euo pipefail
trap handle_exit EXIT

# Make sure we have one arg
if [ $# -ne 1 ]; then
    choose_instance
else
    INSTANCE="$1"
fi

case $INSTANCE in
    main)
        turn_on_main
        ;;
    lancer)
        turn_on_lancer
        ;;
    *)
        usage
        exit
        ;;
esac
