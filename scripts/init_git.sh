#!/bin/bash
set -eo pipefail

VERSION_PATTERN="^v[0-9]+\.[0-9]+\.[0-9]+(-[a-z_]+)?$"
RELEASE_BRANCH_PATTERN="^release/v[0-9]+\.[0-9]+\.x(-[a-z_]+)?$"
RELEASE_BRANCH_TARGETED_PATTERN="^release/([a-z]+)/v[0-9]+\.[0-9]+\.x(-[a-z_]+)?$"
DETECTED_VERSION=$(git tag -l --points-at HEAD | awk '{printf $1}')
