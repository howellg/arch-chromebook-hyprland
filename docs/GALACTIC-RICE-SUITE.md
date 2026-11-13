# Galactic Command: Five-Part Desktop Upgrade

**Target:** Arch Linux on Acer Chromebook (Hyprland Lua 0.57.2, Waybar, Wofi, GTK3, Hyprlock, Kitty and Fish). The artwork and names reference only Star Wars Episodes I–VI and Legends/EU-inspired systems.

This is an optional, reversible appearance/workflow layer over the existing Imperial/Sith/Rakatan setup. Original Catppuccin settings are retained under `~/.local/state/starwars-theme/catppuccin-original/`. A separate full pre-upgrade archive is in `~/.local/state/starwars-theme/rice-suite-20261112-232955/live-config.tar.gz` on the original Chromebook.

## Components and keys

| Interface | What it does | Access |
| --- | --- | --- |
| Galactic Command Waybar | Compact angular panels and event-driven sector indicator (no Waybar restart on workspace switch). Preserves Wi-Fi, audio, CPU, memory, brightness, battery, tray, quick settings, power, etc. | Automatically shown |
| Imperial / Sith / Rakatan Security | Sci-fi Hyprlock clock, authorization heading, themed access-code box. Authentication still uses normal Hyprlock/PAM. | Super+L (unchanged) |
| HoloNet launcher | Applications, recent folders, safe diagnostics/system commands, per-faction terminal profiles, theme controls. Menu only allows selected entries; no arbitrary shell string execution. | **Super+Shift+O**, or search HoloNet |
| Tactical Quick Settings | Floating GTK command console, live read-only status of Syncthing, Tailscale, network and battery, and all existing Wi-Fi/Bluetooth/volume/brightness/power controls. | **Super+Shift+Q** |
| Terminal profiles | Sith (workspace 2), Rakatan (workspace 3), Imperial (workspace 1): individual Kitty colors and nonintrusive Fish startup banner. **Existing custom Fish prompt is not overwritten.** | HoloNet → Terminals, menu apps, or `galactic sith` etc. |

**Super+Space** still opens your immediate application search; **Super+Shift+Y** still opens Galactic Appearance. Ordinary Kitty, Firefox, Discord, VS Code and Desktop Commander workspace assignments are unchanged. Only explicitly launched themed Kitty windows use the new class-based workspace rules.

## Switching and recovery

```fish
~/.local/bin/hypr-starwars set imperial
~/.local/bin/hypr-starwars set sith
~/.local/bin/hypr-starwars set rakatan
~/.local/bin/hypr-starwars restore      # Exact Catppuccin files + Waybar layout
~/.local/bin/hypr-holonet-launcher
~/.local/bin/hypr-galactic-terminal sith
~/.local/bin/hypr-galactic-terminal rakatan
```

The Star Wars manager now records the **original Waybar configuration JSON** as well as the original CSS and lock-screen settings before replacing it. Catppuccin restoration restores the original Waybar modules—including the window-title module—and removes the custom sector module. The new HoloNet and Kitty launchers may remain installed but do not affect the Catppuccin appearance.

## Implementation details

- Waybar's `custom/sector` runs `hypr-galactic-status --follow`. It listens to Hyprland's `.socket2.sock` for workspace/focus events and streams JSON to Waybar (`tail: true`). This updates the indicator without a bar process restart or continuous wallpaper animation. The faction class changes with the sector.
- `galactic_styles.py` contains the Waybar, GTK3 Quick Settings and Hyprlock skins. Hyprland's existing wallpaper fade is controlled by `awww`; its rendering remains static at 1920×1200.
- Waybar retains every existing interactive utility module. A new, clickable sector indicator replaces only the focused-window title text; the current window title remains available in the sector tooltip.
- HoloNet is separate from the normal Wofi application launcher; it lists only actual top-level project folders, launches programs via argument lists, and never executes an arbitrary typed shell command.
- Kitty uses two merged configuration files: the user's unchanged `kitty.conf`, then a matching `galactic-*.conf` preset. Fish runs a one-time color banner while keeping the existing custom `fish_prompt.fish`.
- Tactical Quick Settings uses existing NetworkManager, Bluetooth, PipeWire, brightnessctl, powerprofilesctl and desktop-mode commands. The status cards are **read-only**; existing action buttons retain their former behavior.

## Tested on the Chromebook

- Python syntax, Fish syntax, Lua syntax, desktop-file validation, GTK CSS parsing: passed.
- Waybar process PID stayed unchanged during multiple workspace transitions; sector status JSON reflected workspace 1 and 3; existing system modules remained present.
- GTK Tactical Console launched and was recognized by Hyprland as a **floating** window. Closed test window after validation.
- Wofi HoloNet console launched successfully as a layer surface and was closed afterward.
- The Sith Kitty profile launched with class `galactic-sith`. The Rakatan Kitty profile launched with class `galactic-rakatan` on workspace **3**. Test terminal processes were closed afterward.
- Catppuccin restoration recovered both the old Waybar JSON layout and the original Hyprlock file **byte-for-byte**; selecting Imperial again restored `custom/sector`.
- Hyprland reported no configuration errors; no logout or MySQL restart was required.

**Security and known limits:** Hyprlock was deliberately *not used to lock the live laptop* during remote tests, because this could disrupt access. Its generated layout passes static configuration checks but needs a physical lock/unlock visual check on your next convenient login. GTK and Waybar status colors are deliberately lightweight; there is no continual animated background or audio/music playback. Some visual changes apply when a new window is launched rather than recoloring existing Kitty windows.
