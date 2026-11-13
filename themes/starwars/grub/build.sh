#!/usr/bin/env bash
set -euo pipefail
src=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
out=${1:?Specify the output directory}
regular=/usr/share/fonts/TTF/JetBrainsMonoNLNerdFont-Regular.ttf
bold=/usr/share/fonts/TTF/JetBrainsMonoNLNerdFont-Bold.ttf
if [[ ! -r "$regular" || ! -r "$bold" ]]; then
    printf '%s\n' "Install ttf-jetbrains-mono-nerd before building this theme." >&2
    exit 1
fi
mkdir -p "$out"
cp "$src/theme.txt" "$out/theme.txt"
rsvg-convert --width 1920 --height 1200 --output "$out/bridge.png" "$src/../bridge.svg"
grub-mkfont -n "Imperial Mono" -s 18 -r 32-255 -o "$out/regular.pf2" "$regular"
grub-mkfont -n "Imperial Mono" -b -s 26 -r 32-255 -o "$out/bold.pf2" "$bold"

tile() {
    local name=$1 color=$2 width=$3 height=$4
    printf '<svg xmlns="http://www.w3.org/2000/svg" width="%s" height="%s"><rect width="100%%" height="100%%" fill="%s"/></svg>\n' \
        "$width" "$height" "$color" | rsvg-convert --output "$out/$name.png"
}
tile panel_c '#131722' 4 4
for edge in n ne e se s sw w nw; do
    tile "panel_$edge" '#4d3c4a' 1 1
done
tile selected_c '#392632' 4 4
tile selected_w '#ed7775' 3 4
