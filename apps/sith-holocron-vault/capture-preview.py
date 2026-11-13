"""Capture a small preview of the focused, visible window before Vault opens."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import base64
import json
import re
import subprocess


WORKSPACES = (1, 2, 3, 4, 5, 9)
HELPER = Path.home() / ".local/share/sith-holocron-vault/workspace-capture"


def query(command):
    return json.loads(subprocess.check_output(["hyprctl", command, "-j"], timeout=.5))


def workspace_preview(workspace):
    try:
        data = subprocess.check_output(
            [HELPER, workspace["name"]], timeout=2.2, stderr=subprocess.DEVNULL
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    if 0 < len(data) < 60000:
        return f'{workspace["id"]}:' + base64.b64encode(data).decode("ascii")
    return ""


def capture_workspaces():
    if not HELPER.is_file():
        return set()
    occupied = [ws for ws in query("workspaces")
                if ws["id"] in WORKSPACES and ws.get("windows", 0) > 0]
    with ThreadPoolExecutor(max_workers=3) as pool:
        previews = list(pool.map(workspace_preview, occupied))
    for preview in previews:
        if preview:
            print(preview)
    return {int(preview.split(":", 1)[0]) for preview in previews if preview}


def capture_focused(captured):

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
    if workspace in captured or workspace not in WORKSPACES or monitor["activeWorkspace"]["id"] != workspace:
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
        capture_focused(capture_workspaces())
    except (OSError, ValueError, KeyError, subprocess.SubprocessError):
        pass
