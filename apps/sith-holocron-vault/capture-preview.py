"""Capture a small preview of the focused, visible window before Vault opens."""
import base64
import json
import re
import subprocess


def capture():
    def query(command):
        return json.loads(subprocess.check_output(["hyprctl", command, "-j"], timeout=.5))

    window = query("activewindow")
    address = window.get("address", "")
    if not re.fullmatch(r"0x[0-9a-f]+", address):
        return
    if not window.get("mapped", True) or window.get("hidden", False):
        return
    monitor = next((m for m in query("monitors") if m["id"] == window["monitor"]), None)
    if not monitor or monitor.get("transform", 0) != 0:
        return
    workspace = window.get("workspace", {}).get("id")
    if workspace not in (1, 2, 3, 4, 5, 9) or monitor["activeWorkspace"]["id"] != workspace:
        return
    x, y = window["at"]
    width, height = window["size"]
    mx, my = monitor["x"], monitor["y"]
    left, top = max(x, mx), max(y, my)
    right = min(x + width, mx + int(monitor["width"] / monitor["scale"]))
    bottom = min(y + height, my + int(monitor["height"] / monitor["scale"]))
    width, height = right - left, bottom - top
    if min(width, height) < 32:
        return
    scale = min(1, 440 / width, 300 / height)
    data = subprocess.check_output(
        ["grim", "-g", f"{left},{top} {width}x{height}", "-s", str(scale),
         "-t", "jpeg", "-q", "68", "-"],
        timeout=1,
    )
    if 0 < len(data) < 60000 and query("activewindow").get("address") == address:
        print(address + ":" + base64.b64encode(data).decode("ascii"))


if __name__ == "__main__":
    try:
        capture()
    except (OSError, ValueError, KeyError, subprocess.SubprocessError):
        pass
