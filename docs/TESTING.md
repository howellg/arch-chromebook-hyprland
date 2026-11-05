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
