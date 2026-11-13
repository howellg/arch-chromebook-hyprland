"""Cinematic but lightweight Star Wars UI skins. No persistent state or external commands."""
import json
import shlex
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
    right = config.setdefault("modules-right", [])
    if "custom/comms" not in right:
        index = right.index("custom/settings") if "custom/settings" in right else len(right)
        right.insert(index, "custom/comms")
    log = shlex.quote(str(home / ".local/bin/hypr-notifications"))
    config["custom/comms"] = {
        "exec": log + " --waybar",
        "return-type": "json",
        "interval": 3,
        "format": "{text}",
        "on-click": log,
        "on-click-right": "makoctl mode -t do-not-disturb",
        "tooltip": True,
    }
    if "network" in right:
        right[right.index("network")] = "custom/holonet-link"
    link = shlex.quote(str(home / ".local/bin/hypr-holonet-link"))
    config["custom/holonet-link"] = {
        "exec": link + " --waybar",
        "interval": 15,
        "return-type": "json",
        "format": "{text}",
        "on-click": link,
        "on-click-right": config.get("network", {}).get("on-click", "nm-connection-editor"),
        "tooltip": True,
    }
    if "custom/arch" in config:
        config["custom/arch"]["format"] = "\ue900"  # TIE fighter
    workspaces = config["hyprland/workspaces"]
    workspaces["format"] = "{icon} {name}"
    workspaces["format-icons"].update({
        str(id): chr(0xE901 + index) for index, id in enumerate(SECTORS)
    })
    monitor = shlex.quote(str(home / ".local/bin/hypr-command-monitor"))
    for module in ("cpu", "memory"):
        if module in right:
            index = right.index(module)
            if "custom/command-bridge" not in right:
                right.insert(index, "custom/command-bridge")
            right.remove(module)
    config["custom/command-bridge"] = {
        "format": "\ue906",
        "tooltip": True,
        "tooltip-format": "Command Bridge · System Monitor",
        "on-click": monitor,
    }
    # Keep all buttons where they already were: avoid hiding Wi-Fi, battery, etc.
    return json.dumps(config,ensure_ascii=False,indent=4)+"\n"

def waybar(p,original):
    a=p["accent"]; edge=p["edge"]; bg=p["bg"]; card=p["card"]
    txt=p["text"]; muted=p["muted"]
    return f"""/* STAR WARS // GALACTIC COMMAND // event-driven sector status */
* {{
    font-family: "Galactic Sector","JetBrainsMono Nerd Font",monospace;
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
#custom-arch,#workspaces,#custom-sector,#clock,#custom-command-bridge,#custom-holonet-link,
#pulseaudio,#backlight,#battery,#tray,#custom-power,#custom-settings,
#custom-power-profile,#custom-comms {{
    background:linear-gradient(to bottom, #242630, #11131b);
    border:1px solid #3b3e4a;
    border-bottom:1px solid alpha({a},.68);
    border-radius:0 7px 0 7px;
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
    color:#fff0ec; background:alpha({a},.26);
    box-shadow:inset 0 -2px {a};
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
#custom-command-bridge {{color:{a}; font-size:15px; padding:3px 9px;}}
#custom-command-bridge:hover {{background:alpha({a},.22);}}
#custom-holonet-link {{color:{txt};}}
#custom-holonet-link.linked {{color:{a};}}
#custom-holonet-link.degraded {{color:#e9bf84;}}
#custom-holonet-link.offline,#custom-holonet-link.unknown {{color:{muted};}}
#custom-holonet-link:hover {{background:alpha({a},.22);}}
#pulseaudio {{color:{txt};}}
#backlight {{color:{txt};}}
#battery {{color:{txt};}}
#battery.warning {{color:#f4b66e;}}
#battery.critical {{color:#f0777d;}}
#battery.charging {{color:#81d9c2;}}
#tray {{padding:3px 5px;}}
#custom-settings {{color:{a}; font-size:15px;}}
#custom-power {{color:#ec626c; font-size:16px; padding:2px 9px;}}
#custom-power-profile {{color:{a};}}
#custom-comms {{color:{muted}; padding:4px 8px;}}
#custom-comms.quiet {{border-top-color:#d6af6a;}}
#custom-comms.unread {{color:{a};}}
#custom-comms.priority {{
    color:#ff9ba2; border-color:#f36e7c;
    background:#3a202d; box-shadow:inset 0 -2px #ff6776;
}}
#custom-comms.priority.quiet {{border-top-color:#d6af6a;}}
#custom-comms.offline {{opacity:.6;}}
#custom-arch:hover,#custom-settings:hover,#custom-power:hover,
#custom-sector:hover,#custom-power-profile:hover,#custom-comms:hover {{
    background:alpha({a},.22);
}}
"""

def quick(p):
    a=p["accent"]; bg=p["bg"]; card=p["card"]; txt=p["text"]; muted=p["muted"]
    edge=p["edge"]
    return f"""/* GALACTIC TACTICAL CONSOLE // {p['label']} */
window.quick-settings, window.holonet-search {{
    background-image:linear-gradient(to bottom, #232630, {bg});
    color:{txt}; border:1px solid {edge}; border-bottom:2px solid {a};
    border-radius:0 12px 0 12px;
}}
window.quick-settings label {{color:{txt};font-family:"JetBrainsMono Nerd Font";}}
window.holonet-search .heading {{
    font-family:"Galactic Sector","JetBrainsMono Nerd Font",monospace;
    color:{a};font-size:18px;font-weight:800;letter-spacing:1px;
}}
window.holonet-search entry, window.holonet-search .destination {{
    background:{bg};color:{txt};border:1px solid {edge};
    border-radius:0 8px 0 8px;padding:12px;
}}
window.holonet-search entry:focus {{border-color:{a};}}
window.holonet-search list {{background:{bg};color:{txt};}}
window.holonet-search row {{padding:8px 10px;border-left:2px solid transparent;}}
window.holonet-search row:selected {{
    background:alpha({a},.21);color:{txt};border-left-color:{a};
}}
window.holonet-search .sector-icon {{
    font-family:"Galactic Sector";font-size:16px;color:{a};
}}
window.holonet-search .app-name {{font-weight:800;}}
window.holonet-search .monitor-value {{color:{a};font-size:20px;font-weight:800;}}
window.holonet-search levelbar block {{min-height:5px;border-radius:0;background-image:none;}}
window.holonet-search levelbar block.filled {{background-color:{a};}}
window.holonet-search levelbar block.empty {{background-color:{edge};}}
window.holonet-search button {{
    background-image:none; background-color:{card}; color:{txt};
    border:1px solid {edge}; border-radius:0 7px 0 7px; padding:7px 10px;
}}
window.holonet-search button:hover, window.holonet-search button:focus {{
    border-color:{a}; background:alpha({a},.24);
}}
window.quick-settings levelbar block {{background-image:none;min-height:5px;border-radius:0;}}
window.quick-settings levelbar block.filled {{background:{a};}}
window.quick-settings levelbar block.empty {{background:{edge};}}
window.quick-settings scale marks mark indicator {{color:{muted};min-height:4px;min-width:1px;}}

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
window.quick-settings highlight {{background-image:none;background-color:{a};border-radius:3px;}}
window.quick-settings slider {{
    background-color:{a};border-radius:5px;
    min-width:14px;min-height:14px;
}}
"""

def lock(p, artwork=None):
    def rgb(hexval):
        return "rgb("+", ".join(str(int(hexval[i:i+2],16)) for i in (1,3,5))+")"
    txt=rgb(p["text"]);accent=rgb(p["accent"]);muted=rgb(p["muted"])
    card=rgb(p["card"]);bg=rgb(p["bg"])
    background = f"    path = {artwork}\n" if artwork and artwork.is_file() else ""
    insignia = "\ue901" if p["label"] == "IMPERIAL COMMAND" else "\ue902" if p["label"] == "SITH ARCHIVES" else "\ue903"
    return f"""# Star Wars Imperial Security / Galactic authorization terminal
# Authentication is still handled by Hyprlock/PAM. No custom password handling.
general {{
    hide_cursor = true
}}
background {{
    monitor =
{background}    color = {bg}
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
    text = {insignia}
    color = {accent}
    font_size = 29
    font_family = Galactic Sector
    position = 0, 205
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
    outline_thickness = 2
    rounding = 5
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
    text = {p["label"]}  /  SECURE SESSION
    color = {muted}
    font_size = 12
    font_family = JetBrainsMono Nerd Font
    position = 0, -300
    halign = center
    valign = center
}}
"""
