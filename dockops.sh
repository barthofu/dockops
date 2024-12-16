#!/bin/sh

# Script to pull git repo and restart docker-compose if there is a change.
# The aim is to reproduce a gitops workflow for docker-compose.

# Usage:
# dockops.sh <REPO_URL> <REPO_BRANCH> <LOCAL_PATH> [REPO_SUBDIR] [INFISICAL_CONFIG_FILENAME]

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/lib/utils/loader.sh"

trap "exit 1" ERR

# variables
REPO_URL=${1:-$DOCKOPS_REPO_URL}
REPO_BRANCH=${2:-$DOCKOPS_REPO_BRANCH}
REPO_LOCAL_PATH=${3:-$DOCKOPS_REPO_LOCAL_PATH}
REPO_SUBDIR=${4:-${$DOCKOPS_REPO_SUBDIR:-apps/docker/$(hostname)}}
INFISICAL_CONFIG_FILENAME=${5:-${$DOCKOPS_INFISICAL_CONFIG_FILENAME:-infisical-agent-config.yaml}}

if [ -z "$REPO_URL" ]; then
  echo "REPO_URL is required"
  exit 1
fi

if [ -z "$REPO_BRANCH" ]; then
  echo "REPO_BRANCH is required"
  exit 1
fi

if [ -z "$REPO_LOCAL_PATH" ]; then
  echo "REPO_LOCAL_PATH is required"
  exit 1
fi

if [ -z "$REPO_SUBDIR" ]; then
  echo "REPO_SUBDIR is required"
  exit 1
fi

if [ -z "$INFISICAL_CONFIG_FILENAME" ]; then
  echo "INFISICAL_CONFIG_FILENAME is required"
  exit 1
fi

# Usage:
# check_diff <repo_local_path> <repo_subdir> [branch]
# e.g: check_diff "./local/location" "./local/location/apps/docker/$(hostname)"
check_diff() {
  repo_local_path="${1:-.}" 
  repo_subdir="${2:-.}" 
  branch="${3:-main}"
  
  full_path=$repo_local_path/$repo_subdir
  old_commit=$(git -C "$repo_local_path" log --pretty=tformat:"%h" -n1 .)
  
	git_checkout $branch $repo_local_path
  git_pull $branch $repo_local_path
	status=$?
	if [[ $status -ne 0 ]]; then
		git_stash $repo_local_path
  	git_force_pull $branch $repo_local_path
	fi
  
  new_commit=$(git -C "$repo_local_path" log --pretty=tformat:"%h" -n1 .)
	
	change_has_been_detected=false
  for directory_path in $full_path/*/; do
    changes=$(git -C $repo_local_path diff --name-status $old_commit $new_commit -- "$directory_path")
		if [ -n "$changes" ]; then
      echo "dockops >> Changes detected in $directory_path"
      
			change_has_been_detected=true
      docker_compose_reload $directory_path
		fi
  done

	if ! $change_has_been_detected; then
		echo "dockops >> No changes detected"
	fi
}

main() {

	if ! fs_directory_exists $REPO_LOCAL_PATH; then
		if [ -z "$REPO_SUBDIR" ]; then # useless for the moment, will be used when generic
			git_clone $REPO_URL $REPO_LOCAL_PATH
			git_checkout $REPO_BRANCH $REPO_LOCAL_PATH
		else
			git_sparse_clone $REPO_URL $REPO_BRANCH $REPO_LOCAL_PATH $REPO_SUBDIR
		fi
		infisical_start_agent $REPO_LOCAL_PATH/$REPO_SUBDIR/$INFISICAL_CONFIG_FILENAME
		sleep 5
	fi

	check_diff $REPO_LOCAL_PATH $REPO_SUBDIR $REPO_BRANCH
}

main