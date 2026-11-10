# Chromebook Classroom Center

This optional dashboard is for the Arch Linux / Hyprland Kano Chromebook. Open **Chromebook Classroom Center** from Wofi (`Super+Space`) or Quick Settings (`Super+Shift+Q` → **Classroom**). The desktop entry is installed to `~/.local/share/applications/chromebook-classroom.desktop`.

## Features

- **Battery:** Reads battery capacity, estimated charge/discharge watts and battery health. Existing `hypr-power-profile auto` selects `power-saver` on battery or `balanced` on AC; explicit manual modes and Class/Presentation modes remain available. No TLP/tuned conflicts.
- **Configuration backup:** Daily user timer `chromebook-config-backup.timer` (around 18:00) stores selected desktop config files in `~/.local/state/chromebook-backups`. Archives are mode 0600. The dashboard can create/list and restore one after confirmation, saving a pre-restore backup.
- **Coursework backup:** Manual archives cover `~/Documents` and `~/Projects`, excluding symlinks, Git object stores, caches, virtualenv/node_modules and individual files over 100 MiB. Restore extracts only into a NEW `~/Restored-Coursework` directory; it never overwrites live files.
- **Wi-Fi:** Displays NetworkManager links, cached nearby APs, gateway, DNS. Recovery does a rescan only if Wi-Fi is enabled but disconnected; it never destroys saved campus networks.
- **Study:** Local editable tasks in `~/.local/share/chromebook-study/tasks.txt`, a 25-minute focus timer (runs while dashboard remains open), and one-click Firefox, VS Code, MySQL Workbench New, Dolphin.
- **Wake:** `hypridle.conf` calls `hypr-classroom-wake` after resume. The helper restores the monitor display output and, after a short delay, checks Wi-Fi without interrupting an existing connection. It logs to `~/.local/state/chromebook-classroom/last-resume`. Normal lock-before-suspend remains.
- **Screenshots:** `grim`/`slurp` captures, local `tesseract` text recognition and `wl-copy` for extracted text; existing GTK annotator supports arrows, highlighting, text, and PNG saving.
- **Updates:** `pacman -Qu` checks only the local package metadata, which may be stale. The dashboard links to [Arch News](https://archlinux.org/news/) and opens a Kitty terminal for a **manual** `sudo pacman -Syu`; no updates are installed automatically.
- **Sync:** Displays Syncthing/Tailscale daemon status, Syncthing peer connection counts and folder status where available. Provides Syncthing web UI and user-service launch. No devices or folders are automatically paired.

## Commands

```bash
~/.local/bin/hypr-classroom-core battery
~/.local/bin/hypr-classroom-core net
~/.local/bin/hypr-classroom-core recover
~/.local/bin/hypr-classroom-core sync
~/.local/bin/hypr-classroom-core updates
~/.local/bin/hypr-classroom-core backup
~/.local/bin/hypr-classroom-core backups
~/.local/bin/hypr-classroom-core coursework-backup
~/.local/bin/hypr-classroom-core coursework-list
~/.local/bin/hypr-classroom-core ocr region
systemctl --user status chromebook-config-backup.timer
systemctl --user status syncthing.service
```

For manual configuration restoration use the dashboard's confirmation button. To restore coursework, choose an archive in the dashboard; files go to `~/Restored-Coursework`.

## Security, scope, and setup

The configuration and coursework archives are **local**. They are **not** a full system snapshot, full backup of `~`, or off-device disaster recovery. Copy to a trusted external disk or encrypted remote backup for loss protection.

On this Chromebook, Syncthing was enabled via `systemctl --user enable --now syncthing.service`, but the newly created instance had **zero configured folders and no connected peers** at setup time. Visit http://127.0.0.1:8384 to pair trusted devices and choose explicit folders. Do not publish the Syncthing API key or device private keys.

Tailscale is installed but needs privileged setup and tailnet authentication:

```bash
sudo systemctl enable --now tailscaled.service
sudo tailscale up
```

The first command requires local admin authorization and could not be executed through the remote command policy. No Tailscale account is connected automatically.

Avoid scheduling unattended system updates or forced suspend on a laptop used in class.

## Validation (2026-11-10)

- Python syntax, Bash syntax, desktop-file-validate, systemd service/timer definitions: passed.
- Dashboard and screenshot annotator opened as Hyprland windows: passed (test windows closed).
- Configuration and coursework backup + restore: passed in an isolated temporary HOME, including non-overwriting coursework restoration.
- Real backup timer invocation: exited successfully and created an archive.
- `grim` capture + Tesseract OCR: passed; private recognized text not logged.
- Wake helper manually invoked: exited successfully and did not disrupt connected Wi-Fi.
- Hypridle config parsed and daemon restarted successfully without restarting Hyprland.
- Syncthing service: running/enabled; GUI listening only on 127.0.0.1:8384.
- **Not performed:** actual suspend/resume and projector/phone pairing (these require physical wake/reconnection and real devices). The OCR UI region-selection/copy interaction has not been visually validated.
