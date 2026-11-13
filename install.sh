#!/usr/bin/env bash
# Safe, non-destructive dotfiles installer for an Arch Chromebook.
set -euo pipefail

repo=$(cd "$(dirname "$0")" && pwd)
force=0
dryrun=0
for arg in "$@"; do
  case "$arg" in
    --force) force=1 ;;
    --dry-run) dryrun=1 ;;
    *) echo "Unknown option: $arg (use --force or --dry-run)" >&2; exit 2 ;;
  esac
done

backup="$HOME/.local/state/arch-chromebook-hyprland/backup-$(date +%Y%m%d-%H%M%S)"
copies=0
skips=0

copy_one() {
  local src="$1" dst="$2" rel="$3"
  if [[ -e "$dst" && "$force" != 1 ]]; then
    printf 'SKIP existing: %s  (add --force for a backed-up replacement)\n' "$dst"
    ((skips+=1))
    return
  fi
  if [[ "$dryrun" == 1 ]]; then
    printf 'WOULD install: %s\n' "$dst"
    return
  fi
  if [[ -e "$dst" ]]; then
    mkdir -p "$backup/$(dirname "$rel")"
    cp -p "$dst" "$backup/$rel"
  fi
  mkdir -p "$(dirname "$dst")"
  sed "s|@HOME@|$HOME|g" "$src" > "$dst"
  if [[ "$rel" == bin/* ]]; then chmod 755 "$dst"; fi
  ((copies+=1))
}

while IFS= read -r -d '' src; do
  rel=$(realpath --relative-to="$repo/config" "$src")
  if [[ "$rel" == applications/* ]]; then
    # Desktop launchers belong in XDG_DATA_HOME, not XDG_CONFIG_HOME.
    copy_one "$src" "$HOME/.local/share/$rel" "share/$rel"
  else
    copy_one "$src" "$HOME/.config/$rel" "config/$rel"
  fi
done < <(find "$repo/config" -type f -print0)

while IFS= read -r -d '' src; do
  name=$(basename "$src")
  copy_one "$src" "$HOME/.local/bin/$name" "bin/$name"
done < <(find "$repo/bin" -maxdepth 1 -type f -print0)

if [[ "$dryrun" == 1 ]]; then
  echo "Dry run complete — no changes."
  exit 0
fi
echo "Installed $copies files, skipped $skips."
[[ -d "$backup" ]] && echo "Backup directory: $backup"
# The Galactic theme uses a local symbol font for Waybar.
font="$HOME/.local/share/fonts/GalacticSector.ttf"
install -Dm644 "$repo/themes/starwars/GalacticSector.ttf" "$font"
if command -v fc-cache >/dev/null; then
  fc-cache "$HOME/.local/share/fonts"
fi
# Original Star Wars-inspired wallpapers are generated locally from SVG.
# Do not auto-apply a faction theme: preserve the user's existing selection.
if [[ -f "$repo/themes/starwars/generate_wallpapers.py" ]] && command -v rsvg-convert >/dev/null; then
  python3 "$repo/themes/starwars/generate_wallpapers.py" || echo "Wallpaper generation failed; Catppuccin remains available."
fi
if [[ ! -x "$HOME/.local/bin/awww" ]] && ! command -v awww >/dev/null 2>&1; then
  echo "Tip: sudo pacman -S --needed awww   # optional flicker-free Star Wars wallpaper fades"
fi
mkdir -p "$HOME/.config/chromebook"
printf "%s\n" "$repo" > "$HOME/.config/chromebook/repository-path"

if command -v systemctl >/dev/null; then
  systemctl --user daemon-reload
  for timer in chromebook-battery-watch.timer chromebook-power-profile.timer chromebook-dnd.timer chromebook-config-backup.timer; do
    if [[ -f "$HOME/.config/systemd/user/$timer" ]]; then
      systemctl --user enable --now "$timer"
    fi
  done
fi
echo "Restart your Hyprland session for autostart settings to apply."
echo "Check Hyprland errors using: hyprctl configerrors"
