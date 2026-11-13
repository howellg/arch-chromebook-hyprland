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

## Refined Galactic terminals (November 2026)

The earlier terminal combination was visually cluttered: a faction banner **plus** the full Arch `fastfetch` logo and its long report. The refreshed themed Kitty consoles use a compact five-line mission-status panel (faction, location, Arch, uptime, RAM and battery) and a consistent two-line Fish prompt.

- **Sith Archives:** Crimson highlights, Korriban research-vault introduction, Sith-specific Fish syntax colors. Workspace 2.
- **Rakatan Research:** Cyan/steel-blue holographic palette, Star Map introduction, Rakatan-specific Fish syntax colors. Workspace 3.
- **Imperial Command:** Clean graphite/red command console. Workspace 1 when explicitly launched.
- All use JetBrainsMono Nerd Font Mono, more comfortable terminal padding, a thin beam cursor, cohesive tab colors, and a nearly opaque background to improve legibility.
- The Fish greeting and prompt overrides load only when `STARWARS_TERMINAL_PROFILE` exists, via `config/fish/conf.d/galactic_terminal.fish`. The original `fish_greeting.fish` (including automatic `fastfetch`) and `fish_prompt.fish` remain unchanged for ordinary Kitty/Fish sessions, scripts and SSH.
- The system report is available on demand with `galactic info` or `fastfetch`. `galactic here` opens the terminal corresponding to the current Hyprland workspace (Sith for 2, Rakatan for 3, Imperial elsewhere); `galactic help` lists shortcuts.
- HoloNet → Terminals now includes **Match Active Workspace** as its first choice.
- The new compact startup code requires no Python packages beyond the standard library and reads only local `/proc` and battery sysfs.

### Tests and rollback

`python3 themes/starwars/test_terminal_refresh.py` verifies startup width, faction colors, Kitty config startup, error-status display, default Fish isolation, and profile auto-selection. The existing `test_galactic_suite.py` and `test_theme.py` also pass.

Live configuration was backed up before edits at `~/.local/state/starwars-theme/terminal-refresh-20261112-235847/config-backup.tar.gz`. The original Catppuccin desktop style remains available through `Super+Shift+Y`; ordinary Fish is unchanged even when the desktop uses Star Wars. To restore just the previous terminal presets, extract that backup into your home directory, and remove the optional `galactic_terminal.fish` file if desired. Avoid overwriting later changes without reviewing the archive.

## Default Kitty appearance (November 13, 2026)

The regular `kitty` command now opens with the **Imperial Command** terminal design while Imperial Hybrid is selected. This includes the familiar **Super+Q** binding, auto-started Kitty, application-menu Kitty, and tools that launch Kitty directly. Existing Hyprland shortcuts and class-based workspace rules are unchanged: ordinary Kitty stays assigned to workspace 2.

Implementation:
- `hypr-starwars` now writes an `include galactic-imperial.conf` line to the regular `~/.config/kitty/kitty.conf` (or `galactic-sith.conf` / `galactic-rakatan.conf` when that faction is selected globally). The included profile supplies colors, font, padding, and cursor.
- Only interactive Fish inside Kitty uses `STARWARS_TERMINAL_PROFILE` automatically, and only while an actual Star Wars theme is selected. This loads the compact mission panel and Galactic prompt instead of auto-Fastfetch.
- Explicit `galactic sith`, `galactic rakatan`, and `galactic imperial` windows take precedence over the global default.
- Restoring Catppuccin removes the include by restoring the original Kitty configuration and suppresses implicit Fish theming. Other terminal emulators, scripts, and ordinary non-Kitty Fish remain unchanged.
- On switching to the Sith or Rakatan **global** desktop style, newly opened default Kitty windows follow the selected global style. Imperial Hybrid deliberately defaults to Imperial regardless of workspace accent.
- Existing terminal windows retain their current appearance until reopened. `fastfetch` / `galactic info` remain available for the full hardware report.

Configuration backup: `~/.local/state/starwars-theme/default-terminal-20261113-001802/pre-default-terminal.tar.gz`.

Verification: The isolated reversible-theme test checks the original Kitty file is restored exactly and the expected `include` is written. Fish regression checks confirm implicit Imperial defaults and explicit Sith override. An actual plain `kitty` command launched with an interactive Fish shell returned `imperial`, loaded the Galactic prompt, and exited without configuration warnings.

### Waybar sector symbols and Sith Archives artwork

Galactic Appearance uses an original icon font for the TIE fighter launcher
and six workspace markers: Star Destroyer, Sith holocron, Rakatan device,
comms dish, Imperial datacard, and Death Star. The installer copies the font
locally. Its source is in `themes/starwars/build_sector_font.py`.

Waybar uses graphite panels and thin sector accents. In Imperial Hybrid the
focused window border matches the current sector indicator. Workspace 2 uses
the original 16:10 Korriban corridor SVG in `themes/starwars/sith.svg`.

### HoloNet application search

With Galactic Appearance active, **Super+Space** opens the HoloNet application
search. Type to filter, use the arrow keys to select a result, press Enter to
launch, and press Esc to close. The detail panel shows the destination for
apps with known workspace assignments. Search also includes the Vault,
HoloNet Console, and Tactical Quick Settings. The Catppuccin scheme uses Wofi.

Quick Settings shares the console styling. Volume and brightness show
ten-percent ticks, and the battery card uses a segmented meter.

In an Imperial terminal, `galactic info` pairs the hardware report with
a Death Star. Use `fastfetch` for the standard report.

## Imperial comms notifications

Mako uses a comms-dish glyph and the active faction accent. Critical alerts
use a brighter red. The volume and brightness keys show ten-segment meters
with exact percentages, and repeat presses replace the corresponding popup.
Media control popups stay out of notification history in Galactic themes.

## Fleet Communications log

Open with **Super+Shift+H**, from Tactical Quick Settings, or by
right-clicking Waybar's notification control. Search active and recent Mako
notifications, spot priority transmissions, and manage Do Not Disturb and
scheduled quiet hours. Galactic themes record arrival times for new
notifications in the session runtime directory. Earlier entries remain
readable. Volume and brightness popups are excluded from the log.

The Waybar comms dish counts unread alerts still in Mako and highlights
unread priority alerts. Click it to open the log and acknowledge the current
batch. The Unread filter keeps that batch available in the open window,
along with new arrivals. Use Mark all read to clear those markers and
acknowledge any alerts that arrived while the log was open.

Right-click the dish to toggle Do Not Disturb. An amber top edge shows
when quiet mode is active.

## HoloNet Link

Waybar shows the current Wi-Fi signal or wired state. Click to open the
HoloNet Link panel for Tailscale and AruleWiki's actual Syncthing connection
status. The panel refreshes every 15 seconds and has links to the local
Syncthing dashboard and NetworkManager. Right-click the Waybar indicator
to open NetworkManager directly.

The Arulia Vaults card shows the DM and Player Syncthing folders, including
scanning, pending changes, pause, errors, and completion with AruleWiki.
Folder checks run while the panel is open. They read the local Syncthing
API on loopback and leave the vaults and Syncthing settings untouched.

Use **Open in Obsidian** beside either vault to open its registered Syncthing
folder. Obsidian opens on Workspace 5, Imperial Databank, by default.
