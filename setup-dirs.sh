#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name: setup-dirs.sh
# Description:
#   Automates the creation and permission setup of directories for logging and
#   persistent storage used by Kubernetes applications like MongoDB, Prometheus,
#   and Redis. The script:
#     1. Creates missing directories in specified paths.
#     2. Sets ownership to user ID 1000 and group ID 1000 (typically the first non-root user and group).
#     3. Configures directory permissions to 755 (rwxr-xr-x).
# -----------------------------------------------------------------------------

# Define paths for the application logs and persistent storage
DIRECTORIES=(
  "/mnt/data/kafka-logs"
  "/mnt/data/mongodb-logs"
  "/mnt/data/prometheus-alertmanager"
  "/mnt/data/redis-logs"
  "/mnt/data/redis-logs-auth-server"
)

# Function to check for sudo privileges
check_sudo() {
  # Check if sudo is installed
  if ! command -v sudo &>/dev/null; then
    echo "Error: 'sudo' is required but not installed. Install it with:" >&2
    echo "  apt install sudo  # Debian/Ubuntu" >&2
    echo "  yum install sudo  # CentOS/RHEL" >&2
    exit 1
  fi

  # Check if the user has sufficient sudo privileges to run the script
  if ! sudo -v &>/dev/null; then
    echo "Error: Insufficient sudo privileges to run this script." >&2
    echo "Solutions:" >&2
    echo "  1. If you lack sudo access, contact your administrator." >&2
    echo "  2. If you have sudo access, run the script with 'sudo':" >&2
    echo "     sudo ./setup_directories.sh" >&2
    exit 1
  fi
}

# Function to create directories and set permissions
create_directories() {
  for DIR in "${DIRECTORIES[@]}"; do
    # Create the directory if it doesn't exist
    if [ ! -d "$DIR" ]; then
      echo "Creating directory: $DIR"
      sudo mkdir -p "$DIR"
    fi

    # Set ownership to user ID 1000 and group ID 1000 (first non-root user/group)
    echo "Setting ownership for $DIR"
    sudo chown -R 1000:1000 "$DIR"

    # Set permissions to 755 (rwxr-xr-x)
    echo "Setting permissions for $DIR"
    sudo chmod -R 755 "$DIR"  # Avoiding -R unless necessary for file permissions inside
  done
}

# Check if sudo is installed and user has appropriate privileges
check_sudo

# Execute the directory creation and permission setup
create_directories

echo "Directory setup and permissions configured successfully."
