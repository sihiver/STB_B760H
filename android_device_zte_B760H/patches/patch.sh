#!/bin/bash
ROOT="${PWD}"
MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Applying MT8127 Nougat Patches ==="

while read -r patch; do
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
                if ! git am --whitespace=nowarn --keep-cr "$patch" 2>/dev/null; then
                    git am --abort >/dev/null 2>&1 || true
                    if ! git apply --whitespace=nowarn "$patch"; then
                        echo "  ERROR: could not apply $patch_name in ${rel_dir}" >&2
                        if [ "${rel_dir}" = "frameworks/av" ] || [ "${rel_dir}" = "frameworks/native" ] || [ "${rel_dir}" = "system/core" ]; then
                            exit 1
                        fi
                    fi
                fi
            fi
        ) || exit 1
    else
        echo "Target repository ${rel_dir} not found, skipping."
    fi
done < <(find "${MY_DIR}" -mindepth 2 -type f -name "*.patch" | sort)

echo "=== All Patches Processed ==="
