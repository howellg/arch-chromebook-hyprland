#!/usr/bin/env bash
set -euo pipefail

if (( EUID != 0 )); then
    echo "Run this installer as root to install the SDDM theme." >&2
    exit 1
fi

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
theme_dir=/usr/share/sddm/themes/imperial-command
config=/etc/sddm.conf.d/90-imperial-command.conf
install -d -m755 "$theme_dir" /etc/sddm.conf.d
install -m644 "$source_dir/Main.qml" "$source_dir/metadata.desktop" "$theme_dir/"
install -m644 "$source_dir/../bridge.svg" "$theme_dir/bridge.svg"
temp=$(mktemp /etc/sddm.conf.d/.imperial-command.XXXXXX)
trap 'rm -f "$temp"' EXIT
printf '[Theme]\nCurrent=imperial-command\n' > "$temp"
chmod 644 "$temp"
mv -f "$temp" "$config"
printf '%s\n' "Imperial Command installed. SDDM will read it on the next reboot."
