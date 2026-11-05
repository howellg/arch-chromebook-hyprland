# Chromebook Hyprland desktop enhancements

This project includes Chromebook-specific integrations beyond a basic window manager.

## Quick settings

Open with **Super+Shift+Q** or click the settings icon in Waybar. The GTK3 panel provides:

- Wi-Fi enable/disable (NetworkManager / nmcli)
- Bluetooth enable/disable (BlueZ / bluetoothctl)
- Night Light: temporary warm color or return to the normal schedule (Hyprsunset)
- Power profile: Auto → Power Saver → Balanced → Performance
- Volume and brightness sliders
- Buttons to open network editor, audio mixer, wallpaper picker, window overview, and power menu

Wi-Fi and Bluetooth controls actually change system radio state when clicked. Do not use them while you are relying on the corresponding connection.

## Wallpapers and automatic accent colors

Press **Super+Shift+W**. The picker browses images inside your ~/Pictures/Wallpapers folder. Select "Import image" to copy an existing picture into that folder. Click a thumbnail to set the image through Hyprpaper.

"Match accent colors" (on by default) samples the image to choose a readable accent and updates the Waybar, Wofi, Mako, GTK quick-settings and Kitty accent colors. Theme changes only happen after choosing a wallpaper. The original sample project contains no artwork or copyrighted backgrounds.

The script restarts Waybar and reloads Mako after the palette update. Existing Kitty windows may need reopening for border/cursor color changes. Wallpaper and theme changes are local to your account.

## Touchpad

- Three-finger horizontal swipe: switch workspace
- Four-finger swipe up: visual window overview
- Four-finger swipe down: toggle the magic scratchpad workspace
- Three-finger pinch: desktop cursor zoom

Actual gesture support varies across touchpads.

## Window overview and workspaces

Press Super+Tab or the Chromebook physical Overview key. The GTK grid displays open window titles and workspace names, with captured thumbnails for windows **visible on the currently active workspace**. Offscreen windows show an icon rather than inventing a thumbnail.

Waybar workspaces display application-related icons: Firefox (1), VS Code (2), Discord (3), and Desktop Commander (9). Certain calculators, audio tools, connection editors and file chooser windows open as centered, floating utilities.

## Screenshots and screen recording

- Super+Shift+A: select region → copy screenshot
- Super+Shift+D: select region → save
- Super+Shift+P: select region → open annotation editor
- Super+Shift+R: select region → start a video recording
- Super+Shift+T: stop current video recording

The annotation editor is written in GTK3/Cairo and requires no new third-party screenshot editor. It provides Pen, Arrow, Rectangle, Highlight and Text tools, plus Undo, Copy, and Save PNG. Screenshots are saved in ~/Pictures/Screenshots.

**Recording requires wf-recorder**, which is not included in the base Chromebook installation. Install it with:

    sudo pacman -S --needed wf-recorder

If the package is missing, the start shortcut shows an explanatory notification instead of failing silently. Saved recordings go to ~/Videos/Recordings.

Screen/audio recording privacy: only record material you have permission to capture.

## Battery-aware performance policy

The existing power-profiles-daemon is used for energy profiles. The timer checks AC power every three minutes:

- **Auto**: Balanced on AC, Power Saver on battery
- **Power Saver**, **Balanced**, **Performance**: pin the selected profile

The user-owned setting is in ~/.config/chromebook/power-mode. The default is Auto. Disable with:

    systemctl --user disable --now chromebook-power-profile.timer

The hardware may lack a Performance profile; the service will report the limitation rather than forcibly changing it. Low-battery notifications remain a separate timer.

## Hardware compatibility checker

Run:

    ~/.local/bin/chromebook-hardware-check

For machine-readable diagnostics:

    ~/.local/bin/chromebook-hardware-check --json

This reports model, CPU architecture, GPU/audio controller, battery/backlight device names, top-row key capabilities and optional dependencies. It deliberately omits serials, MAC addresses, accounts, and passwords. The top-row scan assumes a keyboard device exposed under Linux evdev and may require adaptation for a different Chromebook.

## Dependencies

The enhanced GTK utilities require **gtk3, python-gobject, python-cairo**, plus existing Hyprland/Wofi/Waybar/Mako/Grim/Slurp/Hyprpaper tools. Power modes require **power-profiles-daemon** with its system service running. Video recording requires optional **wf-recorder**.

Quick Settings, wallpaper picker, and annotation UI have been syntax-checked but should be tested interactively on your actual Chromebook; a remote terminal check cannot validate touch gestures or visual input.
