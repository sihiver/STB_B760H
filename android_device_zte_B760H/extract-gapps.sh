#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2026 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

VENDOR=gapps
DEVICE=arm_tvstock

# Load extractutils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

CM_ROOT="$MY_DIR"/../../..

HELPER="$MY_DIR"/configs/helpers/extract_utils_gapps.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

SRC="$1"
CLEANUP_DUMP=false

DEFAULT_GAPPS_URL="https://sourceforge.net/projects/opengapps/files/arm/20220215/open_gapps-arm-7.1-tvstock-20220215.zip/download"

if [ -z "$SRC" ]; then
    # Look for existing zip in CM_ROOT or MY_DIR
    FOUND_ZIP=$(find "$CM_ROOT" "$MY_DIR" -maxdepth 2 -name "open_gapps-arm-7.1-tvstock*.zip" 2>/dev/null | head -n 1)
    if [ -n "$FOUND_ZIP" ] && [ -f "$FOUND_ZIP" ]; then
        SRC="$FOUND_ZIP"
        echo "Found local OpenGApps zip: $SRC"
    else
        echo "No source specified and no local zip found. Fetching from SourceForge..."
        SRC="$DEFAULT_GAPPS_URL"
    fi
fi

if [[ "$SRC" =~ ^https?:// ]]; then
    TEMP_ZIP=$(mktemp --suffix=.zip)
    echo "Downloading OpenGApps from $SRC..."
    curl -L -o "$TEMP_ZIP" "$SRC"
    SRC="$TEMP_ZIP"
    CLEANUP_ZIP=true
else
    CLEANUP_ZIP=false
fi

if [ -f "$SRC" ] && [[ "$SRC" == *.zip ]]; then
    TEMP_DUMP=$(mktemp -d)
    echo "Unpacking OpenGApps tar.lz archives from $SRC to $TEMP_DUMP..."
    python3 "$MY_DIR"/configs/helpers/extract_opengapps_zip.py "$SRC" "$TEMP_DUMP/system"
    SRC="$TEMP_DUMP"
    CLEANUP_DUMP=true
fi

# Initialize the helper
setup_vendor "$DEVICE" "$VENDOR" "$CM_ROOT"

extract "$MY_DIR"/configs/helpers/proprietary-gapps.txt "$SRC"

DEVICE_BLOB_ROOT="${CM_ROOT}"/vendor/"${VENDOR}"/"${DEVICE}"/proprietary

"$MY_DIR"/configs/helpers/setup-makefiles-gapps.sh

if [ "$CLEANUP_DUMP" = true ]; then
    rm -rf "$TEMP_DUMP"
fi
if [ "$CLEANUP_ZIP" = true ]; then
    rm -f "$TEMP_ZIP"
fi

echo "OpenGApps tvstock extraction complete."
