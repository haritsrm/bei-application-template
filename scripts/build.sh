#!/bin/bash
set -evo pipefail
CURRENT_DIR="$(dirname "$0")"
. ${CURRENT_DIR}/init_git.sh
if [ -n "${CI_NAME}" ]; then
    . ${CURRENT_DIR}/init_${CI_NAME}.sh
    ./gradlew build
else
    # local build
    ./gradlew build --write-locks
fi


if [[ ${DETECTED_VERSION} =~ ${VERSION_PATTERN} ]]; then
    ./gradlew publishMavenJavaPublicationToMavenRepository -Pversion=${DETECTED_VERSION:1}
fi
if [[ ${FORCE_RELEASE} == "true" ]] || [[ ${GIT_INPUT_REFERENCE} =~ ${RELEASE_BRANCH_PATTERN} ]]; then
    ./gradlew uploadAmiBakingManifest -Pversion=$(git rev-parse --short HEAD)
fi
