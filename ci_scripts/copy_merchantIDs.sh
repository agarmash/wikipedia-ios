# For all workflows, update ApplePayConfig plist with environment vars
ApplePayConfigFile="${CI_WORKSPACE}/Wikipedia/ApplePayConfig.plist"

if [! -f "$ApplePayConfigFile"]; then
    echo "Unable to find ApplePayConfig file to update."
    exit 1
fi

plutil -replace merchantIDTest -string $MERCHANT_ID_TEST $ApplePayConfigFile
plutil -replace merchantIDProd -string $MERCHANT_ID_PROD $ApplePayConfigFile
echo "Merchant IDs successfully copied into ApplePayConfig."

echo "Begin Copy Apple Pay Config Values script"

ApplePayConfigFile="${CI_WORKSPACE}/Wikipedia/ApplePayConfig.plist"

# if [[ "StagingDebug" = "${CONFIGURATION}" ]]; then
#     merchantID=$(/usr/libexec/PlistBuddy -c "Print merchantIDTest" "$ApplePayConfigFile")
#     EntitlementsFile="${CI_WORKSPACE}/Wikipedia/StagingStagingDebug.entitlements"
# elif [[ "Staging" = "${CONFIGURATION}" ]]; then
#     merchantID=$(/usr/libexec/PlistBuddy -c "Print merchantIDTest" "$ApplePayConfigFile")
#     EntitlementsFile="${CI_WORKSPACE}/Wikipedia/StagingStaging.entitlements"
# fi

merchantID=$(/usr/libexec/PlistBuddy -c "Print merchantIDTest" "$ApplePayConfigFile")
EntitlementsFile="${CI_WORKSPACE}/Wikipedia/StagingStagingDebug.entitlements"

InfoPListFile="${CI_WORKSPACE}/Wikipedia/Staging-Info.plist"

echo "${CI_WORKSPACE}"
echo "${CONFIGURATION}"
echo "$merchantID"

echo "Check ApplePayConfig file exists"

echo "$ApplePayConfigFile"

if [ ! -f "$ApplePayConfigFile" ]; then

    if [[ "StagingDebug" = "${CONFIGURATION}" ]]; then
        echo "warning: Unable to find ApplePayConfig. This will cause Apple Pay to fail."
        exit 0
    elif [[ "Staging" = "${CONFIGURATION}" ]]; then
        echo "error:  Unable to find ApplePayConfig. This will cause Apple Pay to fail."
        exit 1
    fi
fi

echo "Check Entitlements file exists"

echo "$EntitlementsFile"

if [ ! -f "$EntitlementsFile" ]; then

    if [[ "StagingDebug" = "${CONFIGURATION}" ]]; then
        echo "warning: Unable to find Entitlements file. This will cause Apple Pay to fail."
        exit 0
    elif [[ "Staging" = "${CONFIGURATION}" ]]; then
        echo "error: Unable to find Entitlements file. This will cause Apple Pay to fail."
        exit 1
    fi
fi

echo "Check Info.plist file exists"

echo "$InfoPListFile"

if [ ! -f "$InfoPListFile" ]; then

    if [[ "StagingDebug" = "${CONFIGURATION}" ]]; then
        echo "warning: Unable to find Info.plist file. This will cause Apple Pay to fail."
        exit 0
    elif [[ "Staging" = "${CONFIGURATION}" ]]; then
        echo "error: Unable to find Info.plist file. This will cause Apple Pay to fail."
        exit 1
    fi
fi

echo "Check that merchantID exists"

echo "$merchantID"

if [ -z "$merchantID" ]; then
    if [[ "StagingDebug" = "${CONFIGURATION}" ]]; then
        echo "warning: Unable to pull merchantID from ApplePayConfig. This will cause Apple Pay to fail."
        exit 0
    elif [[ "Staging" = "${CONFIGURATION}" ]]; then
        echo "error: Unable to pull merchantID from ApplePayConfig. This will cause Apple Pay to fail."
        exit 1
    fi
fi

echo "Update merchantID in Entitlements file"

existingEntitlementsMerchantID=$(/usr/libexec/PlistBuddy -c "Print com.apple.developer.in-app-payments:0" "$EntitlementsFile")
echo "Existing entitlements merchant ID: $existingEntitlementsMerchantID"
if [ -z "$existingEntitlementsMerchantID"]; then
    /usr/libexec/PlistBuddy -c "Add :com.apple.developer.in-app-payments: string '$merchantID'" "$EntitlementsFile"
    echo "Maybe added MerchantID to Entitlements."
    newEntitlementsMerchantID=$(/usr/libexec/PlistBuddy -c "Print com.apple.developer.in-app-payments:0" "$EntitlementsFile")
    echo "New entitlements merchant ID: $newEntitlementsMerchantID"
fi



echo "Update merchantID in Info.plist file"

existingInfoPlistMerchantID=$(/usr/libexec/PlistBuddy -c "Print CustomMerchantID" "$InfoPListFile")
echo "Existing Info plist merchant ID: $existingInfoPlistMerchantID"
if [ -z "$existingInfoPlistMerchantID"]; then
    /usr/libexec/PlistBuddy -c "Add CustomMerchantID string '$merchantID'" "$InfoPListFile"
    echo "Maybe added MerchantID to Info.plist."
    newInfoPlistMerchantID=$(/usr/libexec/PlistBuddy -c "Print CustomMerchantID" "$InfoPListFile")
    echo "New Info plist merchant ID: $newInfoPlistMerchantID"
fi
