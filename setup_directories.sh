#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name: setup_directories.sh
# Description:
#   Automates the creation and permission setup of directories for logging and
#   persistent storage used by Kubernetes applications like MongoDB, Prometheus,
#   and Redis. The script:
#     1. Creates missing directories in specified paths.
#     2. Sets ownership to user ID 1000 and group ID 1000.
#     3. Configures directory permissions to 755 (rwxr-xr-x).
# -----------------------------------------------------------------------------

# Define paths for the application logs and persistent storage
DIRECTORIES=(
  "/mnt/data/kafka-logs"
  "/mnt/data/mongodb-logs"
  "/mnt/data/prometheus-alertmanager"
  "/mnt/data/redis-logs"
)

# Function to create directories and set permissions
create_directories() {
  for DIR in "${DIRECTORIES[@]}"; do
    # Check if directory exists, if not, create it
    if [ ! -d "$DIR" ]; then
      echo "Creating directory: $DIR"
      sudo mkdir -p "$DIR"
    fi

    # Set ownership to user ID 1000 and group ID 1000
    echo "Setting ownership for $DIR"
    sudo chown -R 1000:1000 "$DIR"

    # Set permissions to 755 (rwxr-xr-x)
    echo "Setting permissions for $DIR"
    sudo chmod -R 755 "$DIR"
  done
}

# Execute the directory creation and permission setup
create_directories

echo "Directory setup and permissions complete."
