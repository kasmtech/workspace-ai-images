#!/bin/bash
set -ex

# First command-line argument is the comma-separated list of items
ITEMS_TO_PROCESS="$1"

# INST_SCRIPTS is available from the environment (e.g., /opt/startup/install)
DESTINATION_BASE_DIR="${INST_SCRIPTS}"

echo "prep.sh: Processing items: ${ITEMS_TO_PROCESS}"
echo "prep.sh: Destination base: ${DESTINATION_BASE_DIR}"

mkdir -p "${DESTINATION_BASE_DIR}" # Ensure base destination exists

echo "${ITEMS_TO_PROCESS}" | tr ',' '\n' | while IFS= read -r item_path || [ -n "${item_path}" ]; do
    if [ -z "${item_path}" ]; then
        continue
    fi

    SOURCE_PATH="/install/${item_path}"      # Items are under /install
    DEST_PATH="${DESTINATION_BASE_DIR}/${item_path}"

    if [ -e "${SOURCE_PATH}" ]; then
        echo "Copying ${SOURCE_PATH} to ${DEST_PATH}"
        mkdir -p "$(dirname "${DEST_PATH}")"
        cp -a "${SOURCE_PATH}" "${DEST_PATH}"
    else
        echo "Warning: Source ${SOURCE_PATH} not found. Skipping item '${item_path}'." >&2
    fi
done

echo "prep.sh: Finished."