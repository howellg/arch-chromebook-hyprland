#!/usr/bin/env bash
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
out=${1:?Specify an output directory}
mkdir -p "$out"
install -m644 "$source_dir/imperial-startup.plymouth" "$source_dir/imperial-startup.script" "$out/"
for asset in insignia scan wordmark; do
    rsvg-convert --output "$out/$asset.png" "$source_dir/$asset.svg"
done
