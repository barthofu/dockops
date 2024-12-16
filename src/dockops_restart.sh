#!/bin/sh

# Script to reload docker containers through docker compose.
# It is meant to be used by external cron or services like Infisical agent. 

# Usage:
# dockops_restart.sh <stack_path>

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

source "$DIR/utils/loader.sh"

trap "exit 1" ERR

# variables
STACK_PATH=$1

if [ -z "$STACK_PATH" ]; then
  echo "STACK_PATH is required"
  exit 1
fi

main() {
  docker_compose_reload $STACK_PATH
}

main