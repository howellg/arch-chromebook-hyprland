# Galactic Appearance: Imperial workstation

A reversible, locally rendered Star Wars-inspired theme for the Arch/Hyprland Chromebook, using visual motifs associated only with Episodes I–VI and the Legends/Old Republic era. No sequels material or downloaded assets are used. The wallpaper SVG designs are original procedural artwork: starfields, holocron geometry, fleet consoles, and star-map rings. All existing app shortcuts, auto-start services, workspace rules, Syncthing/Tailscale, and databases remain unchanged.

## Appearance

- Global baseline: Imperial Command (obsidian charcoal, white, crimson holographic lines).
- Workspace 1 (Firefox): Imperial command
- Workspace 2 (Kitty): Sith Archives — crimson holocron
- Workspace 3 (VS Code): Rakatan Research — cyan Star Map and ancient technological motifs
- Workspace 4 (Discord): Fleet Communications — steel blue
- Workspace 5 (MySQL): Imperial Databank — amber
- Workspace 9 (Desktop Commander): Command Bridge — subdued scarlet
- Remaining workspaces inherit the chosen default faction. If a configured workspace is selected, its faction accent overrides the global default.

The watcher reacts to actual Hyprland workspace events (not a polling loop). It recolors the focused border, desktop wallpaper, Waybar, GTK Quick Settings, Wofi, Mako, and lock screen theme when the active workspace changes. Hyprland's existing workspace animations provide movement; the generated backgrounds are *static* for battery life rather than constant video rendering. Existing window contents are not modified. Kitty colors apply to newly opened terminals.

## Switching and rollback

- Press **Super+Shift+Y** to choose Imperial hybrid, Sith global fallback, Rakatan global fallback, or **Restore Catppuccin**.
- Or use **Super+Space → Galactic Appearance**.
- Or use **Super+Shift+Q → Galactic Theme**.
- Shell commands: `hypr-starwars set imperial`, `hypr-starwars set sith`, `hypr-starwars set rakatan`, `hypr-starwars restore`, `hypr-starwars status`.

At first switch, original styling files are copied to `~/.local/state/starwars-theme/catppuccin-original/`. Restoration recovers those exact files (including prior custom accent settings); no system packages are replaced. An additional full pre-theme tar snapshot was created separately on the initial machine at `~/.local/state/starwars-theme/pre-starwars-20261112.tar.gz`. Uninstalling can be done by restoring Catppuccin and removing the optional theme watcher, launcher entry and theme files.

To inspect rendered artwork: `~/.local/share/starwars-theme/wallpapers/`. Assets are rendered by `rsvg-convert` from six original SVGs in `themes/starwars` by `generate_wallpapers.py`. Requires `librsvg`, `hyprpaper`, Wofi and the existing Hyprland desktop components.

## Installation

Use the repository's `install.sh`; existing files are preserved by default (use `--force` only after reviewing the installer's backup behavior). The script generates backgrounds locally but does not automatically switch your theme. After first install use `hypr-starwars set imperial`. Reload Hyprland or sign back in to activate Super+Shift+Y and the watcher.

If launching just the watcher manually:

```bash
nohup ~/.local/bin/hypr-starwars watch >/dev/null 2>&1 </dev/null &
```

## Tests

- `python3 -m py_compile bin/hypr-starwars themes/starwars/generate_wallpapers.py themes/starwars/test_theme.py`
- `python3 themes/starwars/test_theme.py` verifies switch and byte-for-byte rollback in an isolated HOME.
- `luac -p config/hypr/hyprland.lua`, `desktop-file-validate config/applications/galactic-appearance.desktop`, `bash -n install.sh`.
- Preview and verify wallpaper renders with `rsvg-convert`, check Waybar reloading and `hyprctl configerrors`.
- Reversibility is tested before switching on the live desktop.

All wallpaper art and theme styles are configured locally. No licensed logos, soundtracks, or third-party image dependencies are bundled.
