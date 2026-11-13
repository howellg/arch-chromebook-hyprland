"""Cinematic but lightweight Star Wars UI skins. No persistent state or external commands."""
import json
from pathlib import Path

SECTORS={
    1:("IMPERIAL","IMPERIAL INTELLIGENCE","imperial"),
    2:("SITH","SITH ARCHIVES","sith"),
    3:("RAKATAN","RAKATAN RESEARCH","rakatan"),
    4:("COMMS","FLEET COMMUNICATIONS","comms"),
    5:("DATA","IMPERIAL DATABANKS","databank"),
    9:("BRIDGE","COMMAND BRIDGE","bridge"),
}

def waybar_config(original, home):
    config=json.loads(original)
    # All existing controls and clicks are retained.
    left=config.setdefault("modules-left",[])
    if "hyprland/window" in left:
        left[left.index("hyprland/window")]="custom/sector"
    elif "custom/sector" not in left:
        left.append("custom/sector")
    config["custom/sector"]={
        "exec":str(home/".local/bin/hypr-galactic-status")+" --follow",
        "return-type":"json","tail":True,
        "format":"{text}","tooltip":True,
        "on-click":str(home/".local/bin/hypr-starwars-menu"),
        "on-click-right":str(home/".local/bin/hypr-holonet-launcher")
    }
    config["hyprland/workspaces"]["format-icons"].update({
        "1":"󰈹","2":"󰞀","3":"󰨞","4":"󰙯","5":"󰘧","9":"󰚩"})
    # Keep all buttons where they already were: avoid hiding Wi-Fi, battery, etc.
    return json.dumps(config,ensure_ascii=False,indent=4)+"\n"

def waybar(p,original):
    a=p["accent"]; edge=p["edge"]; bg=p["bg"]; card=p["card"]
    txt=p["text"]; muted=p["muted"]
    return f"""/* STAR WARS // GALACTIC COMMAND // event-driven sector status */
* {{
    font-family: "JetBrainsMono Nerd Font",monospace;
    font-size: 11px;
    font-weight: 600;
    min-height: 0;
    border: none;
    box-shadow: none;
}}
window#waybar {{ background: transparent; color:{txt}; }}
tooltip {{
    background: {card}; color:{txt};
    border:1px solid {edge}; border-radius:5px;
    padding:5px;
}}
tooltip label {{color:{txt};}}
#custom-arch,#workspaces,#custom-sector,#clock,#cpu,#memory,#network,
#pulseaudio,#backlight,#battery,#tray,#custom-power,#custom-settings,
#custom-power-profile {{
    background:alpha({bg},.95);
    border:1px solid alpha({edge},.78);
    border-bottom:2px solid alpha({a},.72);
    border-radius:4px;
    padding:4px 7px;
    margin:2px 0;
    color:{txt};
}}
#custom-arch {{
    color:{a}; font-size:17px;
    padding:2px 10px;
    border-left:3px solid {a};
}}
#workspaces {{ padding:2px 3px; }}
#workspaces button {{
    color:{muted};
    background:transparent;
    border-radius:2px;
    padding:2px 6px;
    margin:0 1px;
    min-width:12px;
}}
#workspaces button.active {{
    color:{bg}; background:{a};
    font-weight:800;
}}
#workspaces button.urgent {{ color:#ffffff; background:#d84a55; }}
#workspaces button:hover {{ color:{txt}; background:alpha({a},.32); }}
#custom-sector {{
    color:{a}; font-weight:800; letter-spacing:.8px;
    padding:4px 10px;
}}
#custom-sector.sith {{
    color:#f07588; border-color:#95445e; border-bottom-color:#ed4257;
}}
#custom-sector.rakatan {{
    color:#8ae4eb; border-color:#398c9c; border-bottom-color:#64d5df;
}}
#custom-sector.comms {{
    color:#91c8ed; border-color:#547eaa; border-bottom-color:#81b1da;
}}
#custom-sector.databank {{
    color:#efd096; border-color:#b9995e; border-bottom-color:#d6af6a;
}}
#custom-sector.bridge {{
    color:#f08883; border-bottom-color:#ed6664;
}}
#clock {{ color:{txt}; font-size:11px; font-weight:800; padding:4px 11px; }}
#cpu {{color:#8fb9df;}}
#memory {{color:#bb9fdc;}}
#network {{color:#81c9e1;}}
#pulseaudio {{color:{txt};}}
#backlight {{color:#e6bf81;}}
#battery {{color:#96d0ab;}}
#battery.warning {{color:#f4b66e;}}
#battery.critical {{color:#f0777d;}}
#battery.charging {{color:#81d9c2;}}
#tray {{padding:3px 5px;}}
#custom-settings {{color:{a}; font-size:15px;}}
#custom-power {{color:#ec626c; font-size:16px; padding:2px 9px;}}
#custom-power-profile {{color:{a};}}
#custom-arch:hover,#custom-settings:hover,#custom-power:hover,
#custom-sector:hover,#custom-power-profile:hover {{
    background:alpha({a},.22);
}}
"""

def quick(p):
    a=p["accent"]; bg=p["bg"]; card=p["card"]; txt=p["text"]; muted=p["muted"]
    edge=p["edge"]
    return f"""/* GALACTIC TACTICAL CONSOLE // {p['label']} */
window.quick-settings {{
    background-color:alpha({bg},.98);color:{txt};
    border:2px solid {a};border-radius:6px;
}}
window.quick-settings label {{color:{txt};font-family:"JetBrainsMono Nerd Font";}}
window.quick-settings .heading {{
    color:{a};font-weight:800;font-size:19px;letter-spacing:1px;
    margin-bottom:4px;
}}
window.quick-settings .subtitle {{
    color:{muted};font-size:11px;letter-spacing:.4px;
}}
window.quick-settings .section {{
    color:{a};font-weight:700;font-size:12px;
    margin-top:8px;margin-bottom:3px;
}}
window.quick-settings .status-card {{
    background-color:alpha({card},.93);
    border:1px solid alpha({edge},.8);
    border-left:3px solid {a};border-radius:3px;
    color:{txt};padding:10px 7px;
    font-size:11px;
}}
window.quick-settings button {{
    background-image:none;background-color:alpha({card},.96);
    color:{txt};border:1px solid {edge};
    border-radius:3px;box-shadow:none;padding:7px;
}}
window.quick-settings button:hover {{
    background-color:alpha({a},.22);border-color:{a};
}}
window.quick-settings button:active {{
    background-color:alpha({a},.38);
}}
window.quick-settings trough {{
    min-height:8px;border-radius:3px;background-color:{card};
}}
window.quick-settings highlight {{background-color:{a};border-radius:3px;}}
window.quick-settings slider {{
    background-color:{a};border-radius:5px;
    min-width:14px;min-height:14px;
}}
"""

def lock(p):
    def rgb(hexval):
        return "rgb("+", ".join(str(int(hexval[i:i+2],16)) for i in (1,3,5))+")"
    txt=rgb(p["text"]);accent=rgb(p["accent"]);muted=rgb(p["muted"])
    card=rgb(p["card"]);bg=rgb(p["bg"])
    return f"""# Star Wars Imperial Security / Galactic authorization terminal
# Authentication is still handled by Hyprlock/PAM. No custom password handling.
general {{
    hide_cursor = true
}}
background {{
    monitor =
    color = {bg}
}}
# Brief command heading in the upper third.
label {{
    monitor =
    text = GALACTIC SECURITY
    color = {accent}
    font_size = 32
    font_family = JetBrainsMono Nerd Font
    position = 0, 270
    halign = center
    valign = center
}}
label {{
    monitor =
    text = AUTHORIZED PERSONNEL ONLY
    color = {muted}
    font_size = 14
    font_family = JetBrainsMono Nerd Font
    position = 0, 213
    halign = center
    valign = center
}}
label {{
    monitor =
    text = cmd[update:1000] date +"%H:%M"
    color = {txt}
    font_size = 86
    font_family = JetBrainsMono Nerd Font
    position = 0, 65
    halign = center
    valign = center
}}
label {{
    monitor =
    text = cmd[update:60000] date +"%A, %B %d"
    color = {muted}
    font_size = 18
    font_family = JetBrainsMono Nerd Font
    position = 0, -32
    halign = center
    valign = center
}}
input-field {{
    monitor =
    size = 360, 62
    outline_thickness = 3
    dots_size = 0.19
    dots_spacing = 0.24
    dots_center = true
    outer_color = {accent}
    inner_color = {card}
    font_color = {txt}
    check_color = rgb(93, 159, 183)
    fail_color = rgb(226, 87, 101)
    fade_on_empty = false
    placeholder_text = ACCESS CODE REQUIRED
    position = 0, -173
    halign = center
    valign = center
}}
label {{
    monitor =
    text = IMPERIAL ARCHIVES  /  SECURE SESSION
    color = {muted}
    font_size = 12
    font_family = JetBrainsMono Nerd Font
    position = 0, -300
    halign = center
    valign = center
}}
"""
