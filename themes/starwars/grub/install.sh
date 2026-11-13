#!/usr/bin/env bash
set -euo pipefail
if (( EUID != 0 )); then
    printf '%s\n' "Run this installer as root to update the GRUB theme." >&2
    exit 1
fi

src=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
theme=/boot/grub/themes/imperial-command
cfg=/boot/grub/grub.cfg
defaults=/etc/default/grub.d
dropin=$defaults/99-imperial-command.cfg
scratch=$(mktemp -d)
candidate=
activated=0
dropin_written=0
cleanup() {
    if (( dropin_written && ! activated )); then
        if [[ -f "$scratch/previous-dropin" ]]; then
            install -m644 "$scratch/previous-dropin" "$dropin"
        else
            rm -f -- "$dropin"
        fi
    fi
    if [[ -n "$candidate" ]]; then
        rm -f -- "$candidate" "$candidate.new"
    fi
    rm -rf -- "$scratch"
}
trap cleanup EXIT
test -s "$cfg"
mountpoint -q /boot || {
    printf '%s\n' "Mount the Chromebook boot partition at /boot before installing the theme." >&2
    exit 1
}
bash "$src/build.sh" "$scratch/theme"
install -d -m755 /var/backups
backup=$(mktemp -d /var/backups/grub-imperial.XXXXXX)
cp -- "$cfg" "$backup/grub.cfg"
if [[ -e "$dropin" ]]; then
    cp -- "$dropin" "$scratch/previous-dropin"
    cp -- "$dropin" "$backup/99-imperial-command.cfg"
fi
install -d -m755 "$theme" "$defaults"
install -m644 "$scratch/theme/"* "$theme/"
printf 'GRUB_THEME="%s/theme.txt"\n' "$theme" > "$scratch/dropin"
install -m644 "$scratch/dropin" "$dropin"
dropin_written=1

candidate=$(mktemp /boot/grub/.imperial-config.XXXXXX)
grub-mkconfig -o "$candidate"
grub-script-check "$candidate"
grep -F 'set theme=' "$candidate" | grep -Fq '/grub/themes/imperial-command/theme.txt'
# Require the regenerated menu to preserve the current boot commands and entries.
entry_lines() {
    grep -E '^[[:space:]]*(menuentry |submenu |linux(efi)?[[:space:]]|initrd(efi)?[[:space:]])' "$1" |
        sed 's/^[[:space:]]*//'
}
entry_lines "$cfg" > "$scratch/current-entries"
entry_lines "$candidate" > "$scratch/new-entries"
if ! cmp -s "$scratch/current-entries" "$scratch/new-entries"; then
    printf '%s\n' "GRUB regeneration changed boot entries. The existing menu is still active." >&2
    exit 1
fi
mv -f -- "$candidate" "$cfg"
activated=1
printf 'Imperial GRUB theme installed. Boot configuration backup: %s\n' "$backup"
