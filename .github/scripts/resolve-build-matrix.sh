#!/bin/bash

## Copyright (C) 2026 - 2026 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## Expand build selectors (distro/flavor/target/arch, each possibly "all")
## into a GitHub Actions matrix (JSON, as {"include":[...]}). Encodes:
##   - whonix splits into gateway + workstation builds per combo
##   - iso is kicksecure-only (whonix+iso combos are dropped)
##   - iso builds are --type host; everything else --type vm
##   - amd64 -> ubuntu-24.04, arm64 -> ubuntu-24.04-arm

set -o errexit
set -o nounset
set -o pipefail

distro_in="${1:?distro required}"
flavor_in="${2:?flavor required}"
target_in="${3:?target required}"
arch_in="${4:?arch required}"

expand() {
   ## "all" -> the full value list ($2..); otherwise echo the single value.
   local selected="$1"
   shift
   if [ "$selected" = "all" ]; then
      printf '%s\n' "$@"
   else
      printf '%s\n' "$selected"
   fi
}

mapfile -t distros < <(expand "$distro_in" whonix kicksecure)
mapfile -t flavors < <(expand "$flavor_in" cli lxqt)
mapfile -t targets < <(expand "$target_in" raw virtualbox iso)
mapfile -t arches  < <(expand "$arch_in" amd64 arm64)

entries=()
for distro in "${distros[@]}"; do
   for flavor in "${flavors[@]}"; do
      for target in "${targets[@]}"; do
         for arch in "${arches[@]}"; do
            ## iso is kicksecure-only.
            if [ "$target" = "iso" ] && [ "$distro" != "kicksecure" ]; then
               continue
            fi

            if [ "$target" = "iso" ]; then
               type="host"
            else
               type="vm"
            fi

            if [ "$arch" = "arm64" ]; then
               runner="ubuntu-24.04-arm"
            else
               runner="ubuntu-24.04"
            fi

            ## whonix is a unified build: gateway + workstation must be
            ## built in the SAME job/workspace (workstation export needs
            ## the gateway .raw). So emit ONE entry carrying both flavors
            ## (built sequentially, gateway first). kicksecure is one.
            if [ "$distro" = "whonix" ]; then
               flavor_list="whonix-gateway-${flavor} whonix-workstation-${flavor}"
            else
               flavor_list="kicksecure-${flavor}"
            fi

            entries+=("$(jq -n \
               --arg flavors "$flavor_list" \
               --arg target "$target" \
               --arg arch "$arch" \
               --arg type "$type" \
               --arg runner "$runner" \
               --arg name "${distro}-${flavor}-${target}-${arch}" \
               '{flavors:$flavors, target:$target, arch:$arch, type:$type, runner:$runner, name:$name}')")
         done
      done
   done
done

if [ "${#entries[@]}" -eq 0 ]; then
   printf '%s\n' "resolve-build-matrix: no valid combos for distro='${distro_in}' flavor='${flavor_in}' target='${target_in}' arch='${arch_in}'" >&2
   exit 1
fi

printf '%s\n' "${entries[@]}" | jq -c -s '{include: .}'
