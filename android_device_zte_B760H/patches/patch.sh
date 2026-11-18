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

# ZTE LK bootloader strips BOARD_KERNEL_CMDLINE, so androidboot.selinux=permissive
# never reaches /proc/cmdline; default selinux_status_from_cmdline() to SELINUX_PERMISSIVE.
INIT_CPP="${ROOT}/system/core/init/init.cpp"
if [ -f "${INIT_CPP}" ] && grep -q 'selinux_enforcing_status status = SELINUX_ENFORCING;' "${INIT_CPP}"; then
    echo "Patching system/core/init/init.cpp to default SELinux permissive..."
    sed -i 's/selinux_enforcing_status status = SELINUX_ENFORCING;/selinux_enforcing_status status = SELINUX_PERMISSIVE;/' "${INIT_CPP}"
fi

echo "=== All Patches Processed ==="
