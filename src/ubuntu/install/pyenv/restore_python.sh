#!/bin/bash
set -ex


BACKUP_TARGET=${BACKUP_TARGET:-/var/spool/python_versions/}
EXTRA_PACKAGES=${EXTRA_PACKAGES:-}
export PYENV_ROOT=${PYENV_ROOT:-/opt/pyenv}

install_python() {
  pyenv install "$VERSION"
  pyenv global "$VERSION"
  pip install --upgrade pip
}

# Function to restore pyenv versions
restore_pyenv() {
    local backup_file=$(find "$BACKUP_TARGET" -maxdepth 1 -name "pyenv_version_${VERSION}.*.tar.bz2" | sort -r | head -n1)

    if [ -z "$backup_file" ]; then
        echo "Error: No backup file found for Python version $version in $BACKUP_TARGET - will install via pyenv"
        install_python
    else
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
        pyenv global "$VERSION"
        echo "Restore completed successfully"

        eval "$(pyenv init -)"
        eval "$(pyenv init --path)"
    fi


    if [ -n "$EXTRA_PACKAGES" ]; then
      echo "Installing $EXTRA_PACKAGES"
      pip install $EXTRA_PACKAGES
    fi

    if [ -n "$ML_FRAMEWORK" ]; then
        case "$ML_FRAMEWORK" in
            "TENSORFLOW")
                echo "Installing TensorFlow..."
                pip install 'tensorflow[and-cuda]'
                ;;
            "PYTORCH")
                echo "Installing PyTorch..."
                pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
                ;;
            *)
                echo "Unknown ML framework: $ML_FRAMEWORK"
                echo "Supported frameworks: TensorFlow, PyTorch"
                ;;
        esac
    fi
}

# Usage examples:
# To restore: ./package_python.sh restore <backup_file>

case "$1" in
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
        echo "Usage: $0 {restore <version>}"
        exit 1
        ;;
esac
