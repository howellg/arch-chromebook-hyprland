# Arch Chromebook Hyprland (Kano rev3)

A Chromebook-oriented Hyprland desktop for **Arch Linux** alongside existing KDE Plasma. Uses Catppuccin-inspired Waybar, translucent Wofi menus, Mako, Hyprlock, clipboard history and a low-battery timer.

**Status:** Work in progress. Tested on Acer Chromebook Kano rev3, Intel Core i5-1235U, 1920×1200, Arch Linux, **Hyprland 0.57.x (Lua configuration)**. Other Chromebooks may have different input mappings, battery names, backlights and audio.

## Features

- KDE and SDDM remain usable; choose Hyprland at login
- Chromebook top-row Back/Refresh, Fullscreen, Overview, screenshot, volume and brightness
- Waybar with workspace buttons, current window, system statistics, battery, tray and power menu
- Catppuccin-inspired Wofi app launcher, searchable shortcuts, confirmation-based power menu
- Mako notifications with progress indicator for volume and brightness
- Clipboard history for text and images (Super+Shift+V)
- Lock after 5 minutes, display off after 10 minutes, lock before suspend
- Battery warnings at 20%, 10%, 5%; no unattended suspend by default
- Optional Hyprsunset night light: neutral after 07:00, 4800K after 20:30
- Workspace assignment: Firefox 1, VS Code 2, Discord 3
- Fish Fastfetch greeting and shell theme (optional; custom prompt excluded pending license review)

## Dependencies

Install on a working Arch Linux desktop (not a live USB). Official repository packages:

    sudo pacman -S --needed hyprland kitty fish fastfetch \
      waybar wofi mako hyprlock hypridle hyprpaper \
      hyprpolkitagent hyprlauncher wl-clipboard cliphist \
      grim slurp brightnessctl playerctl network-manager-applet \
      pavucontrol xdg-desktop-portal xdg-desktop-portal-hyprland \
      xdg-desktop-portal-gtk hyprsunset

Firefox, Discord and VS Code are optional shortcuts; their commands must exist (firefox, discord, code). VS Code may come from AUR or vendor packaging, not necessarily official Arch repositories.

## Install


    git clone https://github.com/howellg/arch-chromebook-hyprland.git
    cd arch-chromebook-hyprland
    ./install.sh --dry-run
    ./install.sh

By default the installer **skips any existing configuration files**. To replace them with backed-up versions, explicitly use:

    ./install.sh --force

Backups go to ~/.local/state/arch-chromebook-hyprland/. Home-directory placeholders in published files are substituted on install.

The installer does NOT install packages, change your login shell, modify system files or remove KDE. After installation, choose Hyprland from SDDM.

Adapt application commands, monitor scaling, battery BAT0, intel_backlight and top-row keysyms for different Chromebook models.

## Keybindings

On Chromebooks, Super usually means the Search/Launcher key. Search the full live cheatsheet with **Super + comma**.

| Shortcut | Action |
| --- | --- |
| Super+R / Super+Space | App launcher |
| Super+B | Firefox |
| Super+I | VS Code |
| Super+D | Discord |
| Super+Q | Kitty |
| Super+E | Dolphin |
| Super+Shift+V | Clipboard history |
| Super+Shift+A | Region screenshot to clipboard |
| Super+Shift+D | Region screenshot to file |
| Super+Shift+F | Full screenshot to clipboard |
| Super+Shift+G | Full screenshot to file |
| Super+L | Lock screen |
| Super+Shift+E | Power menu |
| Super+comma | Search all current shortcuts |
| Super+Tab | Search windows |
| Super+1..0 | Switch workspaces 1–10 |
| Super+Shift+1..0 | Move window to workspace |
| Super+Shift+N | Toggle Do Not Disturb |

## Desktop Commander on workspace 9 (optional)

The installer includes a small, optional **Desktop Commander Remote** launcher in
`bin/hypr-desktop-commander`. When you sign into Hyprland, it opens
Kitty with the window class `chromebook-desktop-commander`; a silent
window rule places it on **workspace 9 without stealing focus**.

- Requires Node.js/npm/npx and an existing authorized Desktop Commander Remote setup.
- Uses `npx --yes @wonderwhy-er/desktop-commander@latest remote`. This downloads
  and runs third-party code, so review that package and pin a version if you
  prefer reproducible builds.
- Skips launch if an existing Desktop Commander remote process is detected.
- Keeps the Kitty window open if the process exits, so errors remain visible.
- To opt out, remove or comment out the `hypr-desktop-commander` autostart
  line in `config/hypr/hyprland.lua`.
- The installer does not store device credentials or Desktop Commander tokens.

## Audio & screen sharing

Kano rev3 uses SOF audio with Chromebook-specific codec and UCM configuration. See https://github.com/WeirdTreeThing/chromebook-linux-audio and verify support before running its fix script. Test audio at a safe level, including after suspend; do NOT auto-run audio installers on arbitrary Chromebooks.

Screen sharing requires PipeWire and xdg-desktop-portal-hyprland. Verify in a real Firefox/Discord call that the screen selection chooser works **and the other participant can see the capture**. A running portal alone is not end-to-end confirmation. See docs/TESTING.md.

## Night light

Hyprsunset must be installed separately if you did not install it with the other dependencies. The script only starts it when found, so missing packages won't break Hyprland:

    sudo pacman -S --needed hyprsunset

Log out and back into Hyprland to activate. The schedule is set in config/hypr/hyprsunset.conf.

## Battery & clipboard privacy

Battery monitor checks BAT0 every two minutes, warning at 20%, 10% and 5%. It uses a systemd user timer which can also run in KDE. To disable:

    systemctl --user disable --now chromebook-battery-watch.timer

Auto-suspend at 3% is **off by default**, because it risks interrupting work.

Clipboard history is stored locally and unencrypted, potentially including copied passwords or sensitive text. Clear at any time using:

    ~/.local/bin/hypr-clipboard --clear

Disable the two wl-paste autostart lines in hyprland.lua to stop new history capture. No browser profiles, clipboard databases, SSH keys or secrets belong in this repository.

## Structure

- config/hypr: Lua compositor config, lock, idle and night-light profiles
- config/waybar: bar layout and CSS
- config/wofi: launcher, cheatsheet and power-menu themes
- config/mako: notification theme
- config/cliphist: clipboard retention limits
- config/fish: optional greeting and shell theme (no private variables or third-party custom prompt)
- config/systemd/user: battery timer
- bin: session helper scripts
- docs/TESTING.md: manual verification and safety checklist

The working machine uses default Kitty settings; there is no Kitty override in this snapshot.
