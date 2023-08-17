# For all workflows, update ApplePayConfig plist with environment vars
ApplePayConfigFile="${CI_WORKSPACE}/Wikipedia/ApplePayConfig.plist"

if [! -f "$ApplePayConfigFile" ]; then
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
EntitlementsFile1="${CI_WORKSPACE}/Wikipedia/StagingStagingDebug.entitlements"
EntitlementsFile2="${CI_WORKSPACE}/Wikipedia/StagingStaging.entitlements"

InfoPListFile="${CI_WORKSPACE}/Wikipedia/Staging-Info.plist"

echo "${CI_WORKSPACE}"
echo "${CONFIGURATION}"
echo "$merchantID"

echo "Check ApplePayConfig file exists"

echo "$ApplePayConfigFile"

if [ ! -f "$ApplePayConfigFile" ]; then

    echo "Unable to find ApplePayConfigFile file. This will cause Apple Pay to fail."

    if [[ "StagingDebug" = "${CONFIGURATION}" ]]; then
        echo "warning: Unable to find ApplePayConfig. This will cause Apple Pay to fail."
        exit 0
    elif [[ "Staging" = "${CONFIGURATION}" ]]; then
        echo "error:  Unable to find ApplePayConfig. This will cause Apple Pay to fail."
        exit 1
    fi
fi

echo "Check Entitlements 1 file exists"

echo "$EntitlementsFile1"

if [ ! -f "$EntitlementsFile1" ]; then

    echo "Unable to find Entitlements 1 file. This will cause Apple Pay to fail."

    if [[ "StagingDebug" = "${CONFIGURATION}" ]]; then
        echo "warning: Unable to find Entitlements file. This will cause Apple Pay to fail."
        exit 0
    elif [[ "Staging" = "${CONFIGURATION}" ]]; then
        echo "error: Unable to find Entitlements file. This will cause Apple Pay to fail."
        exit 1
    fi
fi

echo "Check Entitlements 2 file exists"

echo "$EntitlementsFile2"

if [ ! -f "$EntitlementsFile2" ]; then

    echo "Unable to find Entitlements 2 file. This will cause Apple Pay to fail."

    if [[ "StagingDebug" = "${CONFIGURATION}" ]]; then
        echo "warning: Unable to find Entitlements 2 file. This will cause Apple Pay to fail."
        exit 0
    elif [[ "Staging" = "${CONFIGURATION}" ]]; then
        echo "error: Unable to find Entitlements 2 file. This will cause Apple Pay to fail."
        exit 1
    fi
fi

echo "Check Info.plist file exists"

echo "$InfoPListFile"

if [ ! -f "$InfoPListFile" ]; then

    echo "Unable to find Info plsit file. This will cause Apple Pay to fail."

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

    echo "MerchantID missing. This will cause Apple Pay to fail."

    if [[ "StagingDebug" = "${CONFIGURATION}" ]]; then
        echo "warning: Unable to pull merchantID from ApplePayConfig. This will cause Apple Pay to fail."
        exit 0
    elif [[ "Staging" = "${CONFIGURATION}" ]]; then
        echo "error: Unable to pull merchantID from ApplePayConfig. This will cause Apple Pay to fail."
        exit 1
    fi
fi

echo "Update merchantID in Entitlements 1 file"

existingEntitlements1MerchantID=$(/usr/libexec/PlistBuddy -c "Print com.apple.developer.in-app-payments:0" "$EntitlementsFile1")
echo "Existing entitlements 1 merchant ID: $existingEntitlements1MerchantID"
if [ -z "$existingEntitlements1MerchantID"]; then
    /usr/libexec/PlistBuddy -c "Add :com.apple.developer.in-app-payments: string '$merchantID'" "$EntitlementsFile1"
    echo "Maybe added MerchantID to Entitlements 1 file."
    newEntitlements1MerchantID=$(/usr/libexec/PlistBuddy -c "Print com.apple.developer.in-app-payments:0" "$EntitlementsFile1")
    echo "New entitlements 1 merchant ID: $newEntitlements1MerchantID"
fi

echo "Update merchantID in Entitlements 2 file"

existingEntitlements2MerchantID=$(/usr/libexec/PlistBuddy -c "Print com.apple.developer.in-app-payments:0" "$EntitlementsFile2")
echo "Existing entitlements 1 merchant ID: $existingEntitlements2MerchantID"
if [ -z "$existingEntitlements2MerchantID"]; then
    /usr/libexec/PlistBuddy -c "Add :com.apple.developer.in-app-payments: string '$merchantID'" "$EntitlementsFile2"
    echo "Maybe added MerchantID to Entitlements 2 file."
    newEntitlements2MerchantID=$(/usr/libexec/PlistBuddy -c "Print com.apple.developer.in-app-payments:0" "$EntitlementsFile2")
    echo "New entitlements 1 merchant ID: $newEntitlements2MerchantID"
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
