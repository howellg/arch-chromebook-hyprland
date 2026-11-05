# Chromebook desktop integrations

These are user-space enhancements for Hyprland 0.57 Lua on Arch Linux. They preserve KDE Plasma/SDDM and do not automatically install packages or update the system.

## Class and Presentation Modes

Use Quick Settings or these shortcuts:
- Super+Shift+C: Class Mode, enables Mako Do Not Disturb and Power Saver.
- Super+Shift+M: Presentation Mode, enables DND, Balanced and systemd's IDLE inhibitor respected by Hypridle. Manual lock (Super+L) and suspension are not disabled.
- Super+Shift+B: Normal Mode, restores the previous DND and power-policy state when possible.

CLI: hypr-desktop-mode status, normal, class, presentation.

Presentation idle inhibition uses systemd-inhibit --what=idle and is session-scoped. It will not be automatically restarted across logout. Verify that the screen stays awake before a presentation. Do not treat this as protection against manual lock or shutdown.

## KDE Connect

KDE Connect and its daemon were already installed on the test Kano Chromebook; the tray indicator is launched on Hyprland login. Open Quick Settings -> Devices, the KDE Connect tab. Android phones must be paired explicitly from their own KDE Connect app on a reachable network. No pairing keys or device IDs belong in this repository.

## Notification center and quiet hours

Super+Shift+H opens a searchable view of Mako's current notifications and history. Actions restore the most recent expired notification, dismiss visible notifications, and toggle DND.

Quiet hours are optional, default OFF. Configure start and end times on the notification panel (e.g. 22:00 to 07:00). The enabled five-minute user timer checks the schedule, avoids overriding active Class/Presentation Mode, and only removes DND when this scheduler previously set it. Mako history is in memory; dismissing visible notifications does not clear all history.

Disable timer: systemctl --user disable --now chromebook-dnd.timer.

## Named app layouts and restoration

Quick Settings -> App Layouts:
- Study: Firefox and Dolphin
- Programming: Firefox, VS Code and Dolphin
- Personal: Firefox and Discord

Saving an active layout stores only allowlisted application classes. It does not store URLs, tabs, document paths, terminal commands or private app data. Restoring skips already-running programs and uses the existing app workspace rules. Auto restoration is OFF by default and can be enabled per layout.

CLI: hypr-session-layout list, save NAME, restore NAME, auto NAME, auto off.

## Audio and Bluetooth

Super+Shift+K opens a GTK picker listing paired/discovered Bluetooth devices for explicit connect/disconnect, PipeWire audio sinks and sources for output/microphone selection, and Pavucontrol for per-application volume. The KDE Connect tab offers discovery and the device manager.

## External-monitor profiles

Quick Settings -> Displays:
- Save current resolution, scale, arrangement, and refresh rate by name.
- Apply a profile only if the connected set of monitor names matches the saved profile, with an additional confirmation.
- Auto matching-profile restoration is OFF by default. Enable it only after saving a known-good profile; the 30-second timer checks attached monitors.

Uses the Hyprland 0.57 Lua monitor API via hyprctl eval. Different models and projectors need separate testing. The included default laptop profile is local machine state, not shipped to other users.

CLI: hypr-display-profile list, save NAME, apply NAME, auto on/off.

## System maintenance

Quick Settings -> Maintenance shows disk usage, UPower battery metrics, locally known pacman updates, failed user services, and recent boot errors.

It does not automatically update software or query fresh repository versions. The Update Terminal button runs sudo pacman -Syu only after you click it and supply your credentials.

## First-run setup wizard

Quick Settings -> First-Run launches the GTK setup wizard. It detects hardware/dependencies, offers a copyable package command, safe install dry-run, install of missing files, and optional --force replacement with backups. It also exposes optional settings such as display auto restore and quiet hours.

The installer records the repository path only in the local chromebook configuration directory, excluded from Git. It never removes KDE or executes package installation without a deliberate action.

## Testing notes

Check KDE Connect phone pairing, actual Bluetooth audio, presentation-mode idle inhibition, named-layout restore and external-display changes on the real machine. These interactions must not be simulated remotely while the user is working. There is no guarantee that hardware-specific controls work on a different Chromebook.
