#!/bin/bash
#
# main_install.sh
#
# This script iterates through items specified in IMAGE_ITEMS (passed as $1)
# and executes their corresponding install_<item_name>.sh scripts.
# The install_<item_name>.sh scripts are expected to be located in a structure
# under ${INST_SCRIPTS}/install/ that mirrors the item's path.
#
# Example:
# If IMAGE_ITEMS contains "_config/custom_startup" and INST_SCRIPTS is /opt/app_data,
# this script will look for and execute /opt/app_data/install/_config/install_custom_startup.sh.
# If IMAGE_ITEMS contains "my_app", it will look for /opt/app_data/install/install_my_app.sh.

# --- Configuration & Safety ---
set -e # Exit immediately if a command exits with a non-zero status.
# set -u # Treat unset variables as an error (optional, for stricter scripting).
# set -o pipefail # Causes a pipeline to return the exit status of the last command that exited with a non-zero status (optional).

# --- Script Arguments & Environment Variables ---
IMAGE_ITEMS_LIST="$1"

# INST_SCRIPTS is an environment variable pointing to the base directory
# where items were copied by a previous prep.sh, e.g., /opt/startup/install
# The individual install_*.sh scripts are expected in a subdir named "install" under INST_SCRIPTS
INSTALLER_SCRIPTS_BASE_DIR="${INST_SCRIPTS}/install"

# --- Logging Function ---
log() {
    echo "[main_install.sh] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# --- Main Execution ---
log "Starting main installation process."
log "IMAGE_ITEMS list received: '${IMAGE_ITEMS_LIST}'"
log "INST_SCRIPTS (base for item content): '${INST_SCRIPTS}'"
log "Base directory for installer scripts (install_*.sh): '${INSTALLER_SCRIPTS_BASE_DIR}'"

mv "$INST_SCRIPTS/_config/custom_startup/start_custom_startup.fragment" "$STARTUPDIR/custom_startup.sh"
chmod +x "$STARTUPDIR/custom_startup.sh"
mkdir "$STARTUPDIR/custom_startup"

if [ -z "${IMAGE_ITEMS_LIST}" ]; then
    log "IMAGE_ITEMS list is empty. Nothing to process."
    exit 0
fi

if [ -z "${INST_SCRIPTS}" ]; then
    log "Error: INST_SCRIPTS environment variable is not set." >&2
    exit 1
fi

if [ ! -d "${INST_SCRIPTS}" ]; then
    log "Error: Base directory for item content (INST_SCRIPTS='${INST_SCRIPTS}') does not exist." >&2
    exit 1
fi

if [ ! -d "${INSTALLER_SCRIPTS_BASE_DIR}" ];then
    log "Error: Base directory for installer scripts (INSTALLER_SCRIPTS_BASE_DIR='${INSTALLER_SCRIPTS_BASE_DIR}') does not exist." >&2
    log "Please ensure that the 'install' subdirectory containing install_*.sh scripts is present under '${INST_SCRIPTS}'." >&2
    exit 1
fi

# Process each item from the comma-separated list
echo "${IMAGE_ITEMS_LIST}" | tr ',' '\n' | while IFS= read -r item_path_from_arg || [ -n "${item_path_from_arg}" ]; do
    # Trim leading/trailing whitespace from the item_path (robustness)
    item_path=$(echo "${item_path_from_arg}" | awk '{$1=$1};1')

    if [ -z "${item_path}" ]; then
        continue # Skip empty items that might result from "item1,,item2" or similar
    fi

    log "-----------------------------------------------------"
    log "Processing item: '${item_path}'"

    item_directory=$(dirname "${item_path}")
    item_basename=$(basename "${item_path}")

    # Construct the relative path for the specific install script
    # (relative to INSTALLER_SCRIPTS_BASE_DIR)
    install_script_relative_path=""
    if [ "${item_directory}" = "." ]; then
        # Item is at the root level, e.g., "only_office"
        # Script will be: install_only_office.sh
        install_script_relative_path="install_${item_basename}.sh"
    else
        # Item is in a subdirectory, e.g., "_config/custom_startup"
        # Script will be: _config/install_custom_startup.sh
        install_script_relative_path="${item_directory}/install_${item_basename}.sh"
    fi

    FULL_INSTALL_SCRIPT_PATH="${INSTALLER_SCRIPTS_BASE_DIR}/${install_script_relative_path}"

    log "Looking for individual installer script: ${FULL_INSTALL_SCRIPT_PATH}"

    if [ -f "${FULL_INSTALL_SCRIPT_PATH}" ]; then
        if [ -x "${FULL_INSTALL_SCRIPT_PATH}" ]; then
            log "Executing: ${FULL_INSTALL_SCRIPT_PATH}"
            # Execute the script.
            # If the script needs context like the item's path in $INST_SCRIPTS,
            # you might pass it as an argument: "${FULL_INSTALL_SCRIPT_PATH}" "${INST_SCRIPTS}/${item_path}"
            if "${FULL_INSTALL_SCRIPT_PATH}"; then
                log "Successfully executed ${FULL_INSTALL_SCRIPT_PATH} for item '${item_path}'."
            else
                # set -e will cause script to exit if FULL_INSTALL_SCRIPT_PATH returns non-zero
                log "Error during execution of ${FULL_INSTALL_SCRIPT_PATH} for item '${item_path}'. Exit code: $?." >&2
                # If not using 'set -e', you'd want to 'exit 1' here.
            fi
        else
            log "Warning: Installer script '${FULL_INSTALL_SCRIPT_PATH}' found but is not executable. Skipping for item '${item_path}'." >&2
        fi
    else
        log "Warning: Installer script '${FULL_INSTALL_SCRIPT_PATH}' not found. Skipping installation for item '${item_path}'." >&2
    fi
done

cat "$INST_SCRIPTS/_config/custom_startup/end_custom_startup.fragment" >> "$STARTUPDIR/custom_startup.sh"
rm -rf "$INST_SCRIPTS"

chown 1000:0 "$HOME"

log "-----------------------------------------------------"
log "Main installation process finished."