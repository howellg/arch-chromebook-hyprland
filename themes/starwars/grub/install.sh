#!/usr/bin/env bash
set -euo pipefail
if (( EUID != 0 )); then
    printf '%s\n' "Run this installer as root to update the GRUB theme." >&2
    exit 1
fi

src=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
theme=/boot/grub/themes/imperial-command
cfg=/boot/grub/grub.cfg
custom=/boot/grub/custom.cfg
begin='# BEGIN Imperial Command theme'
end='# END Imperial Command theme'
scratch=$(mktemp -d)
candidate=
cleanup() {
    if [[ -n "$candidate" ]]; then
        rm -f -- "$candidate"
    fi
    rm -rf -- "$scratch"
}
trap cleanup EXIT

mountpoint -q /boot || {
    printf '%s\n' "Mount the Chromebook boot partition at /boot before installing the theme." >&2
    exit 1
}
if ! grep -Fq 'source ${config_directory}/custom.cfg' "$cfg"; then
    printf '%s\n' "The current GRUB configuration does not load custom.cfg." >&2
    exit 1
fi

bash "$src/build.sh" "$scratch/theme"
candidate=$(mktemp /boot/grub/.imperial-custom.XXXXXX)
if [[ -e "$custom" ]]; then
    # Preserve any user entries and replace only the block owned by this installer.
    awk -v begin="$begin" -v end="$end" '
        $0 == begin { if (inside) exit 1; inside = 1; next }
        $0 == end { if (!inside) exit 1; inside = 0; next }
        !inside { print }
        END { if (inside) exit 1 }
    ' "$custom" > "$candidate"
fi
printf '%s\n' "$begin" >> "$candidate"
cat >> "$candidate" <<'GRUB'
if [ -f "$prefix/themes/imperial-command/theme.txt" ]; then
    if loadfont "$prefix/fonts/unicode.pf2"; then
        if [ -z "$gfxmode" ]; then
            set gfxmode=auto
        fi
        load_video
        insmod gfxterm
        insmod gfxmenu
        insmod png
        if terminal_output gfxterm; then
            loadfont "$prefix/themes/imperial-command/regular.pf2"
            loadfont "$prefix/themes/imperial-command/bold.pf2"
            set theme="$prefix/themes/imperial-command/theme.txt"
            export theme
        fi
    fi
fi
GRUB
printf '%s\n' "$end" >> "$candidate"
grub-script-check "$candidate"

install -d -m755 /var/backups "$theme"
backup=$(mktemp -d /var/backups/grub-imperial.XXXXXX)
if [[ -e "$custom" ]]; then
    cp -- "$custom" "$backup/custom.cfg"
fi
install -m644 "$scratch/theme/"* "$theme/"
chmod 644 "$candidate"
mv -f -- "$candidate" "$custom"
printf 'Imperial GRUB theme installed. Configuration backup directory: %s\n' "$backup"
