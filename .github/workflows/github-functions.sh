#!/usr/bin/env bash

# See
#
# - https://docs.travis-ci.com/user/languages/php#Disabling-preinstalled-PHP-extensions
# - https://docs.travis-ci.com/user/languages/php#Custom-PHP-configuration

set -Eeuo pipefail

#######################################
# Gets the PR flags
#
# Globals:
#   TRAVIS_PULL_REQUEST
#   TRAVIS_BRANCH
#
# Arguments:
#   None
#
# Returns:
#   String
#######################################
function get_infection_pr_flags() {
    local flags="";
    local changed_files;

    PR_NUMBER=$(echo $GITHUB_REF | awk 'BEGIN { FS = "/" } ; { print $3 }')

    if ! [[ "${PR_NUMBER}" == "" ]]; then
        git remote set-branches --add origin "$GITHUB_REF";
        git fetch;

        changed_files=$(git diff origin/"$GITHUB_REF" --diff-filter=A --name-only | grep src/ | paste -sd "," -);

        if [ -n "$changed_files" ]; then
            # Set those flags only if there is any changed files detected
            flags="--filter=${changed_files} --ignore-msi-with-no-mutations --only-covered --show-mutations ${flags}";
        fi
    fi

    echo "$flags";
}

# Restore this setting as Travis relies on that
# see https://github.com/travis-ci/travis-ci/issues/5434#issuecomment-438408950
set +u
