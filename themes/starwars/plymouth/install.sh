#!/usr/bin/env bash
set -euo pipefail
if (( EUID != 0 )); then
    printf '%s\n' "Run this installer as root." >&2
    exit 1
fi

src=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
mountpoint -q /boot
test -s /boot/grub/grub.cfg
test -s /boot/initramfs-linux.img
test -s /boot/vmlinuz-linux
if ! command -v plymouth-set-default-theme >/dev/null; then
    printf '%s\n' "Install the Arch plymouth package before running this installer." >&2
    exit 1
fi

theme=/usr/share/plymouth/themes/imperial-startup
plyconf=/etc/plymouth/plymouthd.conf
hook=/etc/mkinitcpio.conf.d/95-imperial-startup.conf
defaults=/etc/default/grub.d/95-imperial-startup.cfg
bootcfg=/boot/grub/grub.cfg
initramfs=/boot/initramfs-linux.img
install -d -m755 /var/backups /etc/mkinitcpio.conf.d /etc/default/grub.d
backup=$(mktemp -d /var/backups/imperial-startup.XXXXXX)
work=$(mktemp -d /boot/.imperial-startup.XXXXXX)
files=("$plyconf" "$hook" "$defaults" "$bootcfg" "$initramfs")
restore_needed=0
boot_files_changed=0
cleanup() {
    if (( restore_needed )); then
        for path in "${files[@]}"; do
            if (( ! boot_files_changed )) && [[ "$path" == "$bootcfg" || "$path" == "$initramfs" ]]; then
                continue
            fi
            saved="$backup/${path##*/}"
            if [[ -e "$saved" ]]; then
                cp -p -- "$saved" "$path" || printf 'Restore failed for %s\n' "$path" >&2
            else
                rm -f -- "$path"
            fi
        done
    fi
    rm -rf -- "$work"
}
trap cleanup EXIT

for path in "${files[@]}"; do
    if [[ -e "$path" ]]; then
        cp -p -- "$path" "$backup/"
    fi
done

# On this Chromebook GRUB loads the Arch kernel from the mounted boot partition.
# Keep the generated menu as-is apart from adding the splash flag to those entries.
awk '
    /^[[:space:]]+linux[[:space:]]+\/vmlinuz-linux[[:space:]]/ {
        found = 1
        if ($0 !~ /[[:space:]]splash([[:space:]]|$)/) sub(/$/, " splash")
    }
    { print }
    END { if (!found) exit 1 }
' "$bootcfg" > "$work/grub.cfg"
grub-script-check "$work/grub.cfg"
bash "$src/build.sh" "$work/theme"
install -d -m755 "$theme"
install -m644 "$work/theme/"* "$theme/"

restore_needed=1
plymouth-set-default-theme imperial-startup
cat > "$hook" <<'HOOK'
# Run Plymouth after systemd and KMS, before the storage hooks.
imperial_hooks=()
imperial_has_plymouth=
for imperial_hook in "${HOOKS[@]}"; do
    imperial_hooks+=("$imperial_hook")
    if [[ "$imperial_hook" == plymouth ]]; then
        imperial_has_plymouth=yes
    fi
done
if [[ -z "$imperial_has_plymouth" ]]; then
    HOOKS=()
    for imperial_hook in "${imperial_hooks[@]}"; do
        HOOKS+=("$imperial_hook")
        if [[ "$imperial_hook" == kms ]]; then
            HOOKS+=(plymouth)
        fi
    done
fi
unset imperial_hooks imperial_hook imperial_has_plymouth
HOOK
cat > "$defaults" <<'DEFAULTS'
# Keep the splash flag when GRUB's menu is regenerated.
case " ${GRUB_CMDLINE_LINUX_DEFAULT:-} " in
    *" splash "*) ;;
    *) GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT:+$GRUB_CMDLINE_LINUX_DEFAULT }splash" ;;
esac
DEFAULTS

mkinitcpio -k /boot/vmlinuz-linux -g "$work/initramfs-linux.img"
lsinitcpio -l "$work/initramfs-linux.img" > "$work/contents"
grep -Fxq 'usr/bin/plymouthd' "$work/contents"
grep -Fxq 'usr/share/plymouth/themes/imperial-startup/imperial-startup.script' "$work/contents"
boot_files_changed=1
mv -f -- "$work/initramfs-linux.img" "$initramfs"
mv -f -- "$work/grub.cfg" "$bootcfg"
restore_needed=0
printf 'Imperial startup splash installed. Previous configuration: %s\n' "$backup"
