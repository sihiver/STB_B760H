ROOT="${PWD}"
DEVICE_DIR="device/zte/B760H"
REPOSITORIES=(
	'external/wpa_supplicant_8'
    'frameworks/av'
    'system/core'
)

for repository in "${REPOSITORIES[@]}"; do
    cd "${ROOT}/${repository}"

    git am --whitespace=nowarn --keep-cr "${ROOT}/${DEVICE_DIR}/patches/${repository}"/*

    cd "${ROOT}"
done
