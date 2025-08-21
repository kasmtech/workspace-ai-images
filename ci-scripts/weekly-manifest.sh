#!/bin/bash

NAME=$1
SANITIZED_BRANCH_DAILY=${SANITIZED_BRANCH}-rolling-daily
SANITIZED_BRANCH=${SANITIZED_BRANCH}-rolling-weekly

tagImage() {
    docker pull "$1"
    docker tag "$1" "$2"
    docker push "$2"
}

manifest() {
    docker manifest push --purge "$1" || :
    docker manifest create "$1" "$2":x86_64-"$3" "$2":aarch64-"$3"
    docker manifest annotate "$1" "$2":aarch64-"$3" --os linux --arch arm64 --variant v8
    docker manifest push --purge "$1"
}

# Manifest for multi pull and push for single arch
# Will pull the daily rolling images and retag them to weekly
if [[ "${TYPE}" == "multi" ]]; then
    # Pulling and retagging daily image
    tagImage "${ORG_NAME}/${NAME}:x86_64-${SANITIZED_BRANCH_DAILY}" "${ORG_NAME}/${NAME}:x86_64-${SANITIZED_BRANCH}"
    tagImage "${ORG_NAME}/${NAME}:aarch64-${SANITIZED_BRANCH_DAILY}" "${ORG_NAME}/${NAME}:aarch64-${SANITIZED_BRANCH}"

    # Manifest tag
    manifest "${ORG_NAME}/${NAME}:${SANITIZED_BRANCH}" "${ORG_NAME}/${NAME}" "${SANITIZED_BRANCH}"
    
# Single arch image just pull and push
else
    tagImage "${ORG_NAME}/${NAME}:${SANITIZED_BRANCH_DAILY}" "${ORG_NAME}/${NAME}:${SANITIZED_BRANCH}"
fi