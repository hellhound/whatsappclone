#!/usr/bin/env sh
PROJECT_FILE_PATH="`dirname $0`/../src/WhatsappClone"
BUNDLE="whatsappclone.app"
PRODUCT_PATH="${PROJECT_FILE_PATH}/build/Debug-iphoneos"
IPA_DIR="${PRODUCT_PATH}"
#PAYLOAD_DIR="${IPA_DIR}/Payload"
PAYLOAD_DIR="${PRODUCT_PATH}/Payload"
pushd "${PROJECT_FILE_PATH}"
/usr/bin/env xcodebuild -configuration Debug  -sdk iphoneos
popd
rm -rf "${PAYLOAD_DIR}"
mkdir -p "${PAYLOAD_DIR}"
#cp "${PROJECT_FILE_PATH}/Resources/iTunesArtwork" "${IPA_DIR}"
cp -RP "${PRODUCT_PATH}/${BUNDLE}" "${PAYLOAD_DIR}/${BUNDLE}"
/usr/bin/env ditto -c -k --keepParent --rsrc "${PAYLOAD_DIR}" "${PRODUCT_PATH}/${BUNDLE}.ipa"
/usr/bin/env curl -# http://testflightapp.com/api/builds.json -o /dev/null \
    -F file="@${PRODUCT_PATH}/${BUNDLE}.ipa" \
    -F api_token="blah"
    -F team_token="meh"
    -F notes="Demo build" \
    -F notify=True \
    -F distribution_lists="demo-list"
