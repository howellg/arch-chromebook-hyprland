#!/usr/bin/env python3
"""Non-destructive validation of Galactic styles, Waybar JSON and launchers."""
import json
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[2]/"bin"))
from galactic_styles import waybar_config,waybar,quick,lock
P={"bg":"#0b1019","card":"#151f2b","text":"#e8e9e8",
   "muted":"#abb6c2","accent":"#ed6664","edge":"#677383","label":"IMPERIAL COMMAND"}
root=Path(__file__).resolve().parents[2]
original=json.loads((root/"config/waybar/config.jsonc").read_text())
configured=json.loads(waybar_config(json.dumps(original),Path("/home/testing")))
assert "custom/sector" in configured["modules-left"]
assert "hyprland/window" not in configured["modules-left"]
for module in ("network","cpu","memory","pulseaudio","backlight","battery",
               "custom/settings","custom/power-profile","tray","custom/power"):
    assert module in configured["modules-right"],module
assert configured["custom/sector"]["tail"] is True
assert configured["hyprland/workspaces"]["on-click"] == original["hyprland/workspaces"]["on-click"]
print("PASS: sector module + all original Waybar controls")
try:
    import gi
    gi.require_version("Gtk","3.0")
    from gi.repository import Gtk
    for label,data in (("Waybar",waybar(P,"")),("Quick Settings",quick(P))):
        provider=Gtk.CssProvider()
        failures=[]
        provider.connect("parsing-error",lambda _provider,section,error:failures.append(error.message))
        provider.load_from_data(data.encode("utf-8"))
        assert not failures,(label,failures)
        print("PASS:",label,"GTK CSS")
except ImportError:
    print("SKIP: Gtk CSS validation (PyGObject not present)")
screen=lock(P)
assert "input-field {" in screen and "ACCESS CODE REQUIRED" in screen and "GALACTIC SECURITY" in screen
for profile in ("imperial","sith","rakatan"):
    content=(root/f"config/kitty/galactic-{profile}.conf").read_text()
    assert "background " in content and "foreground " in content
print("PASS: Hyprlock skin and Kitty profiles")
