#!/bin/sh

# Stop running the script in case a command returns
# a nonzero exit code.
set -e

if [[ ${CI_WORKFLOW} == "Run Tests" ]]; then
	./copy_sourceroot.sh
	echo "Execute copy source root."
	exit 0
fi

# For all workflows, update ApplePayConfig plist with environment vars
ApplePayConfigFile="${CI_WORKSPACE}/Wikipedia/ApplePayConfig.plist"

if [! -f "$ApplePayConfigFile"]; then
    echo "Unable to find ApplePayConfig file to update."
    exit 1
fi

plutil -replace merchantIDTest -string $MERCHANT_ID_TEST $ApplePayConfigFile
plutil -replace merchantIDProd -string $MERCHANT_ID_PROD $ApplePayConfigFile
echo "Merchant IDs successfully copied into ApplePayConfig."

exit 0
