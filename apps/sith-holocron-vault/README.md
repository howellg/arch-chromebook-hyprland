# Sith Holocron Vault — Godot 4.7

A self-contained **actual 3D** Star Wars Legends/KOTOR-inspired Hyprland workspace picker. The Sith chamber, stone floor, circular dais, columns, six floating holocrons, rotating Rakatan core and holographic lighting are all constructed at runtime with Godot primitives and custom geometry. **No AI images, downloaded game models, fonts, music, or licensed textures are used.**

The design aims for a stylized *KOTOR remade with around-2012 graphical fidelity*: dark Korriban masonry and red Sith artifact lighting with subtle cyan Rakatan technology. The Intel Iris Xe-friendly OpenGL Compatibility renderer is used at a 45 FPS cap. The application runs only while the picker is open.

## Three navigation views

- **S — Sith Holocron Vault (default):** Six physical 3D holocrons orbit a fixed central altar in an ancient Sith chamber, each mapped to a real Hyprland workspace.
- **G — Rakatan Star Map:** 3D planets connected by cyan hyperspace routes.
- **I — Imperial Holotable:** Command-center display with six tactical sectors.

Open the Vault with **Super+Tab** or **Super+Shift+J**, or search **Sith Holocron Vault** in the application launcher. The Chromebook’s physical Overview key opens the GTK window grid.

## Controls

| Input | Result |
| --- | --- |
| Arrow keys | Highlight preceding/next workspace |
| 1, 2, 3, 4, 5, 9 | Highlight that workspace |
| Enter / Space | Switch to highlighted workspace |
| Escape | Close without switching |
| Click a holocron/planet | Switch to that workspace |
| Hover a holocron | Update selected workspace |
| Click a sector button | Switch to that workspace |
| S, G, I | Change between Vault, Star Map, and Holotable |

### Live workspace labels

| Workspace | UI label | Usage |
| --- | --- | --- |
| 1 | CITADEL / CORUSCANT | Firefox, web |
| 2 | SITH ARCHIVES / KORRIBAN | Kitty terminal |
| 3 | RAKATAN FORGE / LEHON | VS Code, development |
| 4 | HOLONET / CORELLIA | Discord, communications |
| 5 | IMPERIAL DATABANK / BYSS | MySQL |
| 9 | COMMAND RELAY / DEATH STAR | Desktop Commander |

The information panel reads actual window titles and counts with `hyprctl clients -j` every 3 seconds. It does not invent application states or collect telemetry. Only six hard-coded workspace identifiers are accepted as destinations. Switching calls Hyprland's Lua dispatcher with a validated number and then quits the application.

## Installation

On Arch Linux, install Godot 4.7+:

```bash
sudo pacman -S --needed godot
```

On the original Chromebook, Godot **4.7.2** is available locally under `~/.local/opt/godot-4.7.2/` as a portable official binary, verified using the official `SHA512-SUMS.txt` checksum. It doesn't change Pacman's package database.

Run the app from your cloned `arch-chromebook-hyprland` repository:

```bash
~/.local/bin/hypr-sith-vault
```

To edit the Godot project:

```bash
godot --editor --path ~/Projects/arch-chromebook-hyprland/apps/sith-holocron-vault
```

If using portable Godot instead, pass the same `--editor --path` arguments to the portable executable. The project's `.godot/` generated import cache is ignored by Git.

The included desktop entry is `config/applications/sith-holocron-vault.desktop`; the launcher wrapper is `bin/hypr-sith-vault`. The repository install script installs these like other desktop utilities. The Hyprland configuration binds **Super+Tab** to the Vault.

## Tests

```bash
godot --headless --path apps/sith-holocron-vault --editor --quit
godot --headless --path apps/sith-holocron-vault --script res://tests/test_bridge.gd
~/.local/bin/hypr-sith-vault -- --self-test
```

The self-test validates scene construction, all three views, focus selection, and local Hyprland data. It never changes the user's workspace. Real GUI rendering on the Chromebook's Intel Iris Xe was tested for the Sith chamber, Star Map, and Holotable. Temporary preview screenshots were stored only under `~/.local/state/sith-vault/`, not committed.

The launcher requests fullscreen. For windowed preview, launch with `--windowed`. The Holotable shows exact window counts on its workspace buttons, with up to six lit indicators per sector. HoloNet’s Recent Workspaces menu uses destinations successfully selected in the Vault and stores only workspace IDs.

## Notes

- Procedural meshes: `scripts/world.gd`
- Live Hyprland integration: `scripts/hypr_bridge.gd`
- Input, camera movement and selection: `scripts/main.gd`
- Data-driven UI: `scripts/hud.gd`
- KOTOR / SWTOR-inspired, not a recreation of a commercial game scene.
- The app exits as soon as a workspace is chosen, keeping continuous GPU use at zero when closed.

The workspace dossier shows window titles and app-type icons. The launcher
captures one small preview of the focused window before opening fullscreen,
when the compositor can supply its visible pixels. Preview pixels stay in
memory. Workspaces without a matching capture show their window list.
