#!/bin/bash
set -eo pipefail
CURRENT_DIR="$(dirname "$0")"

if [ -n "${CI_NAME}" ]; then
    . ${CURRENT_DIR}/init_${CI_NAME}.sh
    . ${CURRENT_DIR}/assume_role.sh -r arn:aws:iam::517530806209:role/BeiartfWriter_bei      # move this to the prebuild step
    echo "${BUILD_COMMAND}"
    eval "${BUILD_COMMAND}"
    if [[ -n "${RELEASE_COMMAND}" ]]; then
        echo "${RELEASE_COMMAND}"
        eval "${RELEASE_COMMAND}"
    fi
    if [[ -n "${SONAR_COMMAND}" ]]; then
        echo "${SONAR_COMMAND}"
        eval "${SONAR_COMMAND} -Dsonar.login=${SONARCLOUD_TOKEN}"
    fi
else
    # local build
    BUILD_COMMAND="./gradlew build --write-locks --no-build-cache"

    # parse command line
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -p) profile="$2"; shift 2;;
        esac
    done

    # run saml of your choice first
    # the next line runs the assume_role, only supplying the -p parameter if it is provided to the build.sh, for example ./scripts/build.sh -p saml
    . ${CURRENT_DIR}/assume_role.sh ${profile:+-p $profile}
    echo "${BUILD_COMMAND}"
    eval "${BUILD_COMMAND}"
fi
