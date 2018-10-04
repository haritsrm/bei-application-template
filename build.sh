#!/bin/bash
set -evo pipefail

./gradlew build
VERSION_PATTERN="^v[0-9]+\.[0-9]+\.[0-9]+(-[a-z_]+)?$"
RELEASE_BRANCH_PATTERN="^release/v[0-9]+\.[0-9]+\.x(-[a-z_]+)?$"
DETECTED_VERSION=$(git tag -l --points-at HEAD | awk '{printf $1}')

echo DETECTED_VERSION=${DETECTED_VERSION}

# release libraries if the commit is tagged with "v<major>.<minor>.<patch>[-optional_metadata]"
if [[ ${DETECTED_VERSION} =~ ${VERSION_PATTERN} ]]; then
    ./gradlew publishMavenJavaPublicationToMavenRepository -Pversion=${DETECTED_VERSION:1}
fi

# release application binaries if the commit is in a release branch"
if [[ ${FORCE_RELEASE} == "true" ]] || [[ ${GIT_INPUT_REFERENCE} =~ ${RELEASE_BRANCH_PATTERN} ]]; then
    ./gradlew uploadAmiBakingManifest -Pversion=$(git rev-parse --short HEAD)
fi
