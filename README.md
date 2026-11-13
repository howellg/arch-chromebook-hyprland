# Arch Chromebook Hyprland (Kano rev3)

A Chromebook-oriented Hyprland desktop for **Arch Linux** alongside existing KDE Plasma. Includes Catppuccin-inspired Waybar, a visual quick-settings panel, wallpaper and accent-color picker, annotated screenshots, touchpad gestures, power profiles, clipboard history, hardware detection, and battery alerts.

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
- Hyprsunset night light: neutral after 07:00, 4800K after 20:30
- Quick Settings panel with Wi-Fi, Bluetooth, power, volume, and brightness controls
- Visual wallpaper picker with generated colors across Waybar, Wofi, Mako, Kitty, and GTK
- Annotated screenshots, optional screen recording, and gesture-based visual overview
- Automatic Power Saver on battery and Balanced on AC, with manual override
- Hardware compatibility report for other Chromebooks
- Workspace assignment: Firefox 1, VS Code 2, Discord 3
- Fish Fastfetch greeting and shell theme (optional; custom prompt excluded pending license review)

## Dependencies

Install on a working Arch Linux desktop (not a live USB). Official repository packages:

    sudo pacman -S --needed hyprland kitty fish fastfetch \
      waybar wofi mako hyprlock hypridle hyprpaper \
      hyprpolkitagent hyprlauncher wl-clipboard cliphist \
      grim slurp brightnessctl playerctl network-manager-applet \
      pavucontrol kdeconnect upower python-gobject python-cairo gtk3 \
      power-profiles-daemon \
      xdg-desktop-portal xdg-desktop-portal-hyprland \
      xdg-desktop-portal-gtk hyprsunset

Firefox, Discord and VS Code are optional shortcuts; their commands must exist (firefox, discord, code). VS Code may come from AUR or vendor packaging, not necessarily official Arch repositories.

Optional video recording requires `wf-recorder` (`sudo pacman -S --needed wf-recorder`). See the **[Feature guide](docs/FEATURES.md)** for instructions on wallpaper theming, gestures, power modes, and the visual tools.

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
| Super+Shift+Q | Quick Settings |
| Super+Shift+W | Wallpaper picker |
| Super+Shift+P | Annotate screenshot |
| Super+Shift+R | Start region recording (needs wf-recorder) |
| Super+Shift+T | Stop recording |

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
- config/chromebook: GTK Quick Settings theme
- config/waybar: bar layout and CSS
- config/wofi: launcher, cheatsheet and power-menu themes
- config/mako: notification theme
- config/cliphist: clipboard retention limits
- config/fish: optional greeting and shell theme (no private variables or third-party custom prompt)
- config/systemd/user: battery timer and automatic AC power-profile timer
- bin: session helper scripts
- docs/TESTING.md: manual verification and safety checklist

The working machine initially uses default Kitty settings; selecting a wallpaper can apply an accent-only Kitty override.

## Further desktop integrations

Hyprland now includes Class and Presentation Modes, KDE Connect support, a searchable Mako notification center with optional quiet hours, named app-session layouts, Bluetooth and PipeWire device pickers, monitor profiles, a read-only maintenance dashboard, and a graphical first-run installer wizard.

- Super+Shift+C: Class Mode / DND + Power Saver
- Super+Shift+M: Presentation Mode / idle inhibition + DND
- Super+Shift+B: return to Normal Mode
- Super+Shift+H: searchable notification center
- Super+Shift+K: Bluetooth / audio / KDE Connect devices
- Super+Shift+Q: full Quick Settings with App Layouts, Displays, Maintenance and First-Run buttons

See [Desktop Integrations](docs/INTEGRATIONS.md) for setup, privacy, limitations, and testing. Scheduled DND, automatic app restoration, and monitor auto-restoration are disabled until explicitly enabled. Manual package upgrades still require confirmation and sudo. KDE Connect phone pairing and projector compatibility must be tested on the actual hardware.

## Classroom Center (November 2026)

A dedicated **Chromebook Classroom Center** now combines automatic battery optimization, local config/coursework backup and safe restore, campus Wi-Fi diagnostics, a study task board and 25-minute timer, post-suspend network checks, screenshot OCR, safe Arch update information, and Syncthing/Tailscale status. Search in Wofi or open Quick Settings → **Classroom**. The installer creates a desktop entry in `~/.local/share/applications` and enables the daily config-backup timer. Syncthing may be enabled separately; Tailscale requires privileged service startup and authentication. See [Classroom Center](docs/CLASSROOM.md) for full commands, limitations, and test results.

## Star Wars / Galactic Appearance

The optional **Galactic Appearance** theme adds original Imperial Command, Sith Archives, and Rakatan Research artwork (Episodes I–VI and Legends visual influences only), an Imperial hybrid with workspace-specific color palettes and backgrounds, and a one-click restoration of your original Catppuccin styling. It preserves existing Hyprland workspaces, shortcuts, application rules, service configuration and classroom utilities.

- **Super+Shift+Y** opens the theme switcher (also available via Wofi search or Quick Settings → Galactic Theme).
- Workspaces **1 / 2 / 3** use Imperial / Sith / Rakatan styling; **4 / 5 / 9** use Fleet Communications / Databank / Command Bridge backgrounds.
- The selector can also apply Sith or Rakatan globally, or fully restore original Catppuccin style files.
- Wallpapers are locally generated from original SVGs without downloading copyrighted images. Movement uses the existing Hyprland animations rather than battery-hungry video wallpapers.

See [Galactic Appearance setup, tests and rollback](docs/STARWARS-THEME.md). Installation requires `rsvg-convert` (librsvg) to generate wallpapers; the installer does not force a theme change.

### Wallpaper fit and seamless switching

The six Star Wars wallpapers are now rendered for the Chromebook's **1920×1200 (16:10)** panel so the headings remain visible. **awww** provides a short fade between workspaces and prevents Hyprpaper's logo flash; the original Hyprpaper is automatically restored with Catppuccin. Hyprland's default logo is disabled, and Waybar is no longer fully reloaded during every workspace change. Install the optional managed backend on new Arch systems with `sudo pacman -S --needed awww` (otherwise the theme falls back to Hyprpaper). See [troubleshooting and recovery](docs/STARWARS-THEME.md).

## Galactic Command Rice Suite

Five integrated Star Wars-inspired workstation upgrades now ship as an optional theme layer: an event-driven Galactic Waybar with per-workspace sector status; a themed Imperial/Sith/Rakatan Hyprlock security terminal; the multi-category HoloNet launcher; floating tactical Quick Settings with live network/sync/battery status; and three distinct Kitty/Fish terminal profiles. **Super+Shift+O** opens HoloNet while **Super+Space** keeps direct application search. Sith and Rakatan profile terminals open on workspaces 2 and 3. No existing Fish prompt, ordinary Kitty keybind, or system control was removed.

The Star Wars manager saves and restores the *original Waybar layout* as well as Catppuccin CSS and lock-screen settings. Read [full usage, testing, and rollback instructions](docs/GALACTIC-RICE-SUITE.md).

### Compact Sith / Rakatan / Imperial terminals

The themed Kitty terminals now use five-line mission-status introductions and matching two-line Fish prompts, instead of displaying a giant `fastfetch` on every launch. Syntax colors, fonts, padding and tab accents match the faction, while regular Fish and Kitty greetings remain unchanged. Use `galactic here` to open the current workspace's theme, `galactic sith`/`galactic rakatan`/`galactic imperial` to pick one, or `galactic info` for the original full fastfetch report. See the [terminal refresh notes](docs/GALACTIC-RICE-SUITE.md#refined-galactic-terminals-november-2026).

**Default terminal:** With Imperial Hybrid active, every ordinary `kitty` launch (including Super+Q) now uses the Imperial command-console colors and compact Fish greeting automatically; explicitly launched Sith/Rakatan consoles still keep their own designs. Catppuccin restores the original Kitty config. See [default terminal setup](docs/GALACTIC-RICE-SUITE.md#default-kitty-appearance-november-13-2026).

## Sith Holocron Vault — Godot 3D workspace picker

A **fully rendered, original 3D** Sith Holocron Vault has been added alongside the existing Hyprland overview. The scene uses KOTOR/Legends-era Sith stone architecture, a rotating Rakatan mechanism, and six selectable floating holocrons. It has two alternate 3D navigation views: **Rakatan Star Map** and **Imperial Holotable**. All geometry is built procedurally in Godot—no AI-generated wallpaper art or third-party models.

Press **Super+Shift+J** (or search **Sith Holocron Vault** in the application launcher) to open it. Arrow keys and number keys highlight a workspace; Enter switches and Esc closes. Switch 3D modes with **S**, **G**, and **I**. Live window titles and counts come from Hyprland, and only whitelisted workspace IDs 1/2/3/4/5/9 can be activated.

**Super+Tab is unchanged.** Godot opens as a separate floating window and quits when switching or closing; the OpenGL Compatibility renderer is limited to 45 FPS for the Chromebook.

Source code, keyboard controls, installation and test instructions: [apps/sith-holocron-vault/README.md](apps/sith-holocron-vault/README.md). Godot 4.7+ is required (`sudo pacman -S godot` on Arch); the Chromebook already has a SHA512-verified portable Godot 4.7.2 installation.
