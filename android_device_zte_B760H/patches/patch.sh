#!/bin/bash
ROOT="${PWD}"
MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Applying MT8127 Nougat Patches ==="

find "${MY_DIR}" -mindepth 2 -type f -name "*.patch" | sort | while read -r patch; do
    rel_dir="$(dirname "${patch#"${MY_DIR}/"}")"
    target_repo="${ROOT}/${rel_dir}"
    patch_name="$(basename "$patch")"
    
    if [ -d "${target_repo}" ]; then
        echo "Applying ${patch_name} to ${rel_dir}..."
        (
            cd "${target_repo}"
            if git apply --reverse --check "$patch" >/dev/null 2>&1; then
                echo "  Already applied, skipping."
            else
                if ! (git am --whitespace=nowarn --keep-cr "$patch" 2>/dev/null || git apply --whitespace=nowarn "$patch"); then
                    echo "  ERROR: could not apply $patch_name in ${rel_dir}" >&2
                    if [ "${rel_dir}" = "frameworks/av" ] || [ "${rel_dir}" = "frameworks/native" ]; then
                        exit 1
                    fi
                fi
            fi
        )
    else
        echo "Target repository ${rel_dir} not found, skipping."
    fi
done

echo "=== All Patches Processed ==="
