#!/usr/bin/env bash
set -euo pipefail
src=$(cd "$(dirname "$0")" && pwd)
out=${1:?Specify an output executable}
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
protocols=$(pkg-config --variable=pkgdatadir wayland-protocols)
for name in ext-foreign-toplevel-list ext-workspace ext-image-capture-source ext-image-copy-capture hyprland-workspace-image-capture-source; do
  xml="$protocols/staging/$name/$name-v1.xml"
  [[ "$name" != hyprland-* ]] || xml="$src/$name-v1.xml"
  wayland-scanner client-header "$xml" "$scratch/$name.h"
  wayland-scanner private-code "$xml" "$scratch/$name.c"
done
cc -O2 -Wall -Wextra -Wno-unused-parameter -I "$scratch" "$src/capture.c" "$scratch/"*.c \
  $(pkg-config --cflags --libs wayland-client libturbojpeg) -o "$scratch/capture"
install -Dm755 "$scratch/capture" "$out"
