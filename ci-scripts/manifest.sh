#! /bin/bash

# Ingest cli variables
## Parse input ##
NAME=$1
TYPE=$2
REVERT_PIPELINE_ID=$3
IS_ROLLING=$4
PULL_BRANCH=${SANITIZED_BRANCH}

# Determine if this is a private or public build
if [[ "${CI_COMMIT_REF_NAME}" == release/* ]] || [[ "${CI_COMMIT_REF_NAME}" == "develop" ]]; then
  ENDPOINT="${NAME}"
else
  ENDPOINT="${NAME}-private"
fi

# Determine if this is a rolling build
if [[ "${SCHEDULED}" != "NO" ]]; then
  if [[ "${SCHEDULE_NAME}" == "NO" ]]; then
    SANITIZED_BRANCH=${SANITIZED_BRANCH}-rolling
  else
    SANITIZED_BRANCH=${SANITIZED_BRANCH}-rolling-${SCHEDULE_NAME}
  fi
fi

# Determine if we are doing a reversion
if [ ! -z "${REVERT_PIPELINE_ID}" ]; then
  # If we are reverting modify the pipeline ID to the one passed
  CI_PIPELINE_ID=${REVERT_PIPELINE_ID}
  if [[ "${IS_ROLLING}" == "true" ]]; then
    if [[ "${SCHEDULE_NAME}" == "NO" ]]; then
      SANITIZED_BRANCH=${SANITIZED_BRANCH}-rolling
    else
      SANITIZED_BRANCH=${SANITIZED_BRANCH}-rolling-${SCHEDULE_NAME}
    fi
  fi
fi

# Manifest for multi pull and push for single arch
if [[ "${TYPE}" == "multi" ]]; then

  # Pull images from cache repo
  docker pull ${ORG_NAME}/image-cache-private:x86_64-${NAME}-${PULL_BRANCH}-${CI_PIPELINE_ID}
  docker pull ${ORG_NAME}/image-cache-private:aarch64-${NAME}-${PULL_BRANCH}-${CI_PIPELINE_ID}

  # Tag images to live repo
  docker tag \
    ${ORG_NAME}/image-cache-private:x86_64-${NAME}-${PULL_BRANCH}-${CI_PIPELINE_ID} \
    ${ORG_NAME}/${ENDPOINT}:x86_64-${SANITIZED_BRANCH}
  docker tag \
    ${ORG_NAME}/image-cache-private:aarch64-${NAME}-${PULL_BRANCH}-${CI_PIPELINE_ID} \
    ${ORG_NAME}/${ENDPOINT}:aarch64-${SANITIZED_BRANCH}

  # Push arches to live repo
  docker push ${ORG_NAME}/${ENDPOINT}:x86_64-${SANITIZED_BRANCH}
  docker push ${ORG_NAME}/${ENDPOINT}:aarch64-${SANITIZED_BRANCH}

  # Manifest to meta tag
  docker manifest push --purge ${ORG_NAME}/${ENDPOINT}:${SANITIZED_BRANCH} || :
  docker manifest create ${ORG_NAME}/${ENDPOINT}:${SANITIZED_BRANCH} ${ORG_NAME}/${ENDPOINT}:x86_64-${SANITIZED_BRANCH} ${ORG_NAME}/${ENDPOINT}:aarch64-${SANITIZED_BRANCH}
  docker manifest annotate ${ORG_NAME}/${ENDPOINT}:${SANITIZED_BRANCH} ${ORG_NAME}/${ENDPOINT}:aarch64-${SANITIZED_BRANCH} --os linux --arch arm64 --variant v8
  docker manifest push --purge ${ORG_NAME}/${ENDPOINT}:${SANITIZED_BRANCH}

# Single arch image just pull and push
else

  # Pull image
  docker pull ${ORG_NAME}/image-cache-private:x86_64-${NAME}-${PULL_BRANCH}-${CI_PIPELINE_ID}

  # Tage image
  docker tag \
    ${ORG_NAME}/image-cache-private:x86_64-${NAME}-${PULL_BRANCH}-${CI_PIPELINE_ID} \
    ${ORG_NAME}/${ENDPOINT}:${SANITIZED_BRANCH}

  # Push image
  docker push ${ORG_NAME}/${ENDPOINT}:${SANITIZED_BRANCH}

fi
