#!/bin/sh

# Stop running the script in case a command returns
# a nonzero exit code.
set -e

if [[ ${CI_WORKFLOW} == "Run Tests" ]]; then
    ./copy_sourceroot.sh
    echo "Execute copy source root."
    exit 0
fi

EntitlementsFile="${CI_PRIMARY_REPOSITORY_PATH}/Wikipedia/Wikipedia.entitlements"

if [[ ${CI_WORKFLOW} == "Weekly Staging Build" ]]; then
    InfoPListFile="${CI_PRIMARY_REPOSITORY_PATH}/Wikipedia/Staging-Info.plist"
    ./copy_environment_vars.sh $EntitlementsFile $InfoPListFile $MERCHANT_ID $PAYMENTS_API_KEY

elif [[ ${CI_WORKFLOW} == "Wikipedia Experimental PR Build" ]]; then
    InfoPListFile="${CI_PRIMARY_REPOSITORY_PATH}/Wikipedia/Experimental-Info.plist"
    ./copy_environment_vars.sh $EntitlementsFile $InfoPListFile $MERCHANT_ID $PAYMENTS_API_KEY

elif [[ ${CI_WORKFLOW} == "Nightly Build" ]]; then
    InfoPListFile="${CI_PRIMARY_REPOSITORY_PATH}/Wikipedia/Wikipedia-Info.plist"
    ./copy_environment_vars.sh $EntitlementsFile $InfoPListFile $MERCHANT_ID $PAYMENTS_API_KEY
fi

exit 0
