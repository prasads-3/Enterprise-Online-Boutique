#!/usr/bin/env bash

set -Eeuo pipefail

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if file exists
check_file() {
    [[ -f "$1" ]]
}

# Check if directory exists
check_directory() {
    [[ -d "$1" ]]
}

# Print current project directory
project_root() {
    git rev-parse --show-toplevel
}
