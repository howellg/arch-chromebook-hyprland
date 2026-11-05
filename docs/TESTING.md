# Manual validation checklist

Do not automatically play loud audio, lock the desktop, reboot, or start a remote screenshare when running these checks.

1. **Hyprland config:** Run hyprctl configerrors and confirm it reports no errors. Confirm Waybar launches and its active-window module is present.
2. **Clipboard:** Copy a nonsensitive line of text, open Super+Shift+V, select it, and paste with Ctrl+V. Repeat with a small public image. Clipboard history is not encrypted; clear using the hypr-clipboard script with --clear.
3. **Volume/brightness:** Tap physical top-row controls. Verify that brightness and volume change and a themed progress notification appears; test audio only at safe volume.
4. **Lock/suspend:** Test Super+L. When ready, suspend and resume, then check touchpad, Wi-Fi and sound devices.
5. **Screen sharing:** Confirm the portal with systemctl --user is-active xdg-desktop-portal-hyprland.service. In Firefox, start a screenshare and select an app/monitor from the chooser. Verify on another device/person that video is received. Repeat with Discord; its screenshare behavior may differ.
6. **Night light:** After installing Hyprsunset and relogging, run hyprctl hyprsunset profile. Neutral at 07:00 and warmer at 20:30. Temporarily disable warmth with hyprctl hyprsunset identity.
7. **Battery:** Run systemctl --user status chromebook-battery-watch.timer to confirm the timer is active. Do not drain to 5% just to test.
8. **Workspaces:** Open new Firefox/VS Code/Discord windows; they should go to workspaces 1/2/3. Existing windows are not forcibly moved.
9. **KDE:** Log into Plasma through SDDM and ensure it still works.
10. **Compatibility:** Copied Lua configuration requires Hyprland 0.55 or newer.

Chromebooks differ in power, audio and input devices. Verify compatibility before adopting the project on other models.

## New feature smoke tests

11. Open Super+Shift+Q and inspect Wi-Fi, Bluetooth, volume, brightness, and power profile status. Avoid toggling the active network during remote work.
12. Open Super+Shift+W, import a local image, select it, and verify wallpaper and accent colors change. No wallpaper is shipped in this repository.
13. Open Super+Shift+P, choose a nonsensitive region, draw a pen stroke, arrow, box, and text. Try Copy and Save PNG. Verify files under ~/Pictures/Screenshots.
14. To test recording, install wf-recorder, press Super+Shift+R, select a region, then stop with Super+Shift+T. Confirm an MP4 is saved in ~/Videos/Recordings.
15. Try the four-finger swipe up/down and three-finger pinch; check these don't interfere with important touchpad behavior.
16. Open the Overview window grid and confirm live thumbnails only appear for windows visible on the current workspace.
17. While on AC, the Auto power policy should choose Balanced. When safely unplugged, it should choose Power Saver after the next timer tick (within three minutes). Verify with powerprofilesctl get; set manual override in Quick Settings.
18. Run chromebook-hardware-check --json and compare battery, backlight, and input capabilities with physical hardware. Do not publish serials or sensitive data.

## New integrations: manual test checklist

19. Verify the three desktop modes in Quick Settings: Class enables DND and saver; Presentation inhibits automatic idle locking but leaves manual Super+L locking intact; Normal restores original settings. Inspect systemd-inhibit --list while presenting. Do not leave Presentation Mode on unattended.
20. Pair your Android phone in KDE Connect, verify file transfer, clipboard and phone notifications. Pairing is never automatic and depends on network discovery.
21. Search recent Mako history in Super+Shift+H. Try quiet hours with safe times, then disable it. Do not run notifications containing personal data in public screenshots.
22. Save a study/programming/personal app layout, restore it, confirm already-running apps aren't duplicated. Auto-login restore requires opt-in.
23. Test the Bluetooth headphones picker, default speaker output, microphone selection and Pavucontrol per-app audio, at safe listening volume.
24. With an external display, save and manually apply a monitor profile. Confirm wrong monitor configurations are refused. Enable automatic matching only after a manual successful test.
25. Inspect maintenance storage, battery and failed-service data. An update terminal should open only when clicked, and pacman should still require manual approval and credentials.
26. Run the first-run wizard's dry run in an isolated account or test home. Confirm the default installer skips existing files and --force makes backups. Verify no private state appears in the public repo.
