#!/bin/bash
set -ex

(/dockerstartup/kasm_default_profile.sh)
sudo update-ca-certificates
export PIP_CERT=/etc/ssl/certs/ca-certificates.crt >> ~/.bashrc
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt >> ~/.bashrc
export PYTHON_CONFIGURE_OPTS="--enable-optimizations --with-lto"
export PYTHON_CFLAGS="-march=native -mtune=native"
export PYENV_ROOT=${PYENV_ROOT:-/opt/pyenv}
source $HOME/.bashrc

BACKUP_TARGET=${BACKUP_TARGET:-/var/spool/python_versions/}
EXTRA_PACKAGES=${EXTRA_PACKAGES:-}

install_python() {
  pyenv install $VERSION
  pyenv global $VERSION
  pip install --upgrade pip
  if [ -n "$EXTRA_PACKAGES" ]; then
    echo "Installing $EXTRA_PACKAGES"
    pip install $EXTRA_PACKAGES
  fi
}
# Function to backup pyenv versions
backup_pyenv() {
    local versions_dir="$PYENV_ROOT/versions"
    
    # Check if versions directory exists
    if [ ! -d "$versions_dir" ]; then
        echo "Error: PyEnv versions directory not found at $versions_dir"
        exit 1
    fi
    
    # Get list of installed versions
    local installed_versions=($(ls "$versions_dir"))
    
    if [ ${#installed_versions[@]} -eq 0 ]; then
        echo "No Python versions found in $versions_dir"
        exit 1
    fi
    local backup_file="pyenv_version_${installed_versions}.tar.bz2"
    
    echo "Found ${#installed_versions[@]} Python version(s)"
    echo "Creating backup archive: $backup_file"
    
    # Create tar.bz2 archive with proper directory structure
    tar -C "$PYENV_ROOT" -cjf "$backup_file" versions/

    if [ -n "$BACKUP_TARGET" ]; then
      sudo mv $backup_file $BACKUP_TARGET
    fi
    echo "Backup completed successfully"
    echo "Backup file: $backup_file"
}

# Function to restore pyenv versions
restore_pyenv() {
    local backup_file=$(find "$BACKUP_TARGET" -maxdepth 1 -name "pyenv_version_${VERSION}.*.tar.bz2" | sort -r | head -n1)

    if [ -z "$backup_file" ]; then
        echo "Error: No backup file found for Python version $version in $BACKUP_TARGET"
        exit 1
    fi
    
    echo "Found backup file: $backup_file"
    local target_dir="$PYENV_ROOT/versions"
    
    # Check if target directory exists, create if it doesn't
    if [ ! -d "$target_dir" ]; then
        echo "Creating target directory: $target_dir"
        mkdir -p "$target_dir"
    fi
    
    echo "Restoring from backup: $backup_file"
    
    # Extract the archive
    tar -C "$PYENV_ROOT" -xjf "$backup_file"
    pyenv global $VERSION
    echo "Restore completed successfully"
}



# Usage examples:
# To backup: ./package_python.sh prepare 3.11 "numpy pandas"
# To restore: ./package_python.sh restore <backup_file>

case "$1" in
    "prepare")
        VERSION=$2
        install_python
        backup_pyenv
        ;;
    "restore")
        if [ -z "$2" ]; then
            echo "Error: Please provide version to restore"
            echo "Usage: $0 restore <version>"
            exit 1
        fi
        VERSION=$2
        restore_pyenv
        ;;
    *)
        echo "Usage: $0 {backup|restore <backup_file>}"
        exit 1
        ;;
esac
