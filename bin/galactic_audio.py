"""Preference shared by Galactic desktop cue producers."""
import os
from pathlib import Path
import subprocess

HOME = Path.home()
MUTE = Path(os.environ.get("XDG_CONFIG_HOME") or HOME / ".config") / "chromebook/galactic-sounds-muted"
THEME = HOME / ".local/state/starwars-theme/selection"
SOUNDS = HOME / ".local/share/starwars-theme/sounds"


def muted():
    return MUTE.exists()


def set_muted(value):
    if value:
        MUTE.parent.mkdir(parents=True, exist_ok=True)
        MUTE.touch()
    else:
        MUTE.unlink(missing_ok=True)


def play(name):
    try:
        if muted() or THEME.read_text().strip() not in ("imperial", "sith", "rakatan"):
            return
        subprocess.Popen(["pw-play", str(SOUNDS / (name + ".wav"))],
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                         start_new_session=True)
    except OSError:
        pass
