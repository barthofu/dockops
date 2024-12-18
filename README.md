# DockOps - GitOps Workflow for Docker-Compose

This script provides a lightweight GitOps workflow for managing Docker Compose deployments. It automatically pulls changes from a Git repository and restarts Docker Compose services if changes are detected.

> [!WARNING]
> This script is intended for my homelab and specific setup. I've made it minimally generic for others to use, but it might require modifications to work in other environments.

> [!INFO]
> This script is meant to be run in a crontab or as a systemd service to keep the local repository in sync with the remote repository. You can also use my [cron-wrapper](https://github.com/barthofu/cron-wrapper) script to run **dockops** in a more controlled manner.

## Features

- Synchronizes a local directory with a remote Git repository.
- Supports sparse cloning of subdirectories within the repository.
- Automatically detects changes in subdirectories and reloads Docker Compose services.
- Integrates with Infisical for secure secrets management.
- Resilient to errors, with mechanisms for stashing and force-pulling if necessary.

## Requirements

- Bash shell (`/bin/sh` compatible).
- Docker and Docker Compose installed and configured.
- Infisical CLI installed and configured (if using `INFISICAL_CONFIG_FILENAME`).
- Git installed and configured.

## Usage

### Command

```sh
./dockops.sh <REPO_URL> <REPO_BRANCH> <LOCAL_PATH> [REPO_SUBDIR] [INFISICAL_CONFIG_FILENAME]
```

### Arguments

1. **`<REPO_URL>`** *(required)*:
   - The URL of the Git repository to pull.
2. **`<REPO_BRANCH>`** *(required)*:
   - The branch of the repository to track.
3. **`<LOCAL_PATH>`** *(required)*:
   - The local directory where the repository will be cloned or updated.
4. **`[REPO_SUBDIR]`** *(optional)*:
   - The subdirectory within the repository to work on. Defaults to `apps/docker/<hostname>`.
5. **`[INFISICAL_CONFIG_FILENAME]`** *(optional)*:
   - Path to the Infisical agent configuration file.

### Example

```sh
export DOCKOPS_REPO_URL="https://github.com/example/repo.git"
export DOCKOPS_REPO_BRANCH="main"
export DOCKOPS_REPO_LOCAL_PATH="/opt/repo"
export DOCKOPS_REPO_SUBDIR="apps/docker/my-host"
export DOCKOPS_INFISICAL_CONFIG_FILENAME="infisical-agent-config.yaml"

./dockops.sh
```

## Environment Variables

The script supports the following environment variables as an alternative to command-line arguments:

- `DOCKOPS_REPO_URL`: The URL of the Git repository.
- `DOCKOPS_REPO_BRANCH`: The branch to track.
- `DOCKOPS_REPO_LOCAL_PATH`: The local directory to clone or update.
- `DOCKOPS_REPO_SUBDIR`: The subdirectory within the repository.
- `DOCKOPS_INFISICAL_CONFIG_FILENAME`: Path to the Infisical configuration file.

## Behavior

1. **Repository Setup**:
   - If the local repository does not exist, it is cloned (sparse clone if `REPO_SUBDIR` is specified).
   - If the local repository exists, the script pulls the latest changes.

2. **Change Detection**:
   - Compares the latest commit to the previous commit for changes in the specified subdirectory.
   - If changes are detected, Docker Compose is reloaded in the modified subdirectories.

3. **Infisical Integration**:
   - Starts the Infisical agent using the specified configuration file, if provided.

4. **Error Handling**:
   - If the Git pull fails, the script attempts to stash changes and force-pull.

## Functions Overview

The script uses utility functions for:

- `git_clone`: Cloning a repository.
- `git_sparse_clone`: Sparse cloning specific subdirectories.
- `git_pull`: Pulling the latest changes.
- `git_checkout`: Checking out the specified branch.
- `git_stash`: Stashing local changes.
- `git_force_pull`: Forcing a pull if errors occur.
- `docker_compose_reload`: Restarting Docker Compose services.
- `docker_compose_up`: Starting Docker Compose services.
- `infisical_start_agent`: Starting the Infisical agent.
- `fs_directory_exists`: Checking if a directory exists.

## Exit Codes

- `0`: Success.
- `1`: General error (e.g., missing variables or invalid input).

## Notes

- Ensure that the `lib/utils/loader.sh` script and its dependencies are available.
- The script requires write access to the local path specified in `REPO_LOCAL_PATH`.
- Make the script executable with `chmod +x dockops.sh`.

## License

This script is open source and may be modified or distributed as needed.
