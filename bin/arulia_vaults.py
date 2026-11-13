"""Resolve the registered Obsidian vaults for the Arulia Syncthing folders."""
import json
import os
from pathlib import Path
import subprocess
from urllib.parse import quote, urlencode
from xml.etree import ElementTree

VAULTS = ("DM", "Player")


def syncthing_config():
    try:
        paths = subprocess.check_output(["syncthing", "paths"], text=True,
                                        stderr=subprocess.DEVNULL, timeout=1).splitlines()
        config_path = Path(paths[paths.index("Configuration file:") + 1].strip())
        return ElementTree.parse(config_path).getroot()
    except (OSError, ValueError, IndexError, ElementTree.ParseError, subprocess.SubprocessError):
        return None


def obsidian_vaults():
    config_home = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    try:
        data = json.loads((config_home / "obsidian/obsidian.json").read_text())
        return {Path(item["path"]).resolve(): id_ for id_, item in data["vaults"].items()
                if item.get("path")}
    except (OSError, ValueError, KeyError, TypeError, AttributeError, RuntimeError):
        return {}


def arulia_vault_id(folder, registered):
    path = folder.get("path") if folder is not None else None
    if path:
        try:
            return registered.get(Path(path).expanduser().resolve())
        except (OSError, RuntimeError, ValueError):
            pass
    return None


def obsidian_open_uri(vault_id):
    return "obsidian://open?" + urlencode({"vault": vault_id}, quote_via=quote)
