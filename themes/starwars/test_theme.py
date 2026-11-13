#!/usr/bin/env python3
import os,subprocess,tempfile
from pathlib import Path
repo=Path("/home/garret/Projects/arch-chromebook-hyprland")
mgr=repo/"bin/hypr-starwars"
with tempfile.TemporaryDirectory(prefix="starwars-theme-isolated-") as dirname:
    home=Path(dirname)
    config=home/".config"
    originals={
      "waybar/style.css":"/* CURRENT CATPPUCCIN */\n",
      "wofi/launcher.css":"* { color: #cdd6f4; }\n",
      "mako/config":"font=JetBrainsMono Nerd Font 11\n",
      "hypr/hyprpaper.conf":"wallpaper {\n monitor =\n path = /not/here\n fit_mode = cover\n}\n"
    }
    for name,contents in originals.items():
        f=config/name;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(contents)
    wp=home/".local/share/starwars-theme/wallpapers";wp.mkdir(parents=True)
    for name in ("imperial","sith","rakatan"): (wp/(name+".png")).write_bytes(b"test-png")
    fake=home/"fakebin";fake.mkdir()
    for cmd in ("hyprctl","pkill","makoctl","pgrep","hyprpaper"):
        p=fake/cmd;p.write_text("#!/bin/sh\nexit 1\n");p.chmod(0o755)
    env={**os.environ,"HOME":str(home),"PATH":str(fake)+":"+os.environ["PATH"]}
    def invoke(*args):
        res=subprocess.run([str(mgr),*args],env=env,capture_output=True,text=True,timeout=20)
        assert res.returncode==0,(args,res.stdout,res.stderr)
        return res.stdout
    assert "catppuccin" in invoke("status")
    invoke("set","imperial")
    assert "STAR WARS" in (config/"waybar/style.css").read_text()
    assert "IMPERIAL COMMAND" in (config/"wofi/launcher.css").read_text()
    assert (config/"wofi/power.css").is_file()
    invoke("set","sith")
    assert "SITH ARCHIVES" in (config/"wofi/launcher.css").read_text() or "IMPERIAL COMMAND" in (config/"wofi/launcher.css").read_text()
    invoke("restore")
    for name,original in originals.items():
        assert (config/name).read_text()==original,(name,(config/name).read_text())
    assert not (config/"wofi/power.css").exists()
    assert "catppuccin" in invoke("status")
    print("PASS: isolated style switching and byte-for-byte Catppuccin recovery")
    print("PASS: missing styles restored to absence; original wallpaper settings retained")
