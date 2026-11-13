#!/usr/bin/env python3
"""Install the Dolphin color scheme and Imperial Databank Places icons."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET

SOURCE = Path(__file__).resolve().parent
HOME = Path.home()
DATA = Path(os.environ.get("XDG_DATA_HOME") or HOME / ".local/share")
STATE = Path(os.environ.get("XDG_STATE_HOME") or HOME / ".local/state")
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME") or HOME / ".config")
KDE = "http://www.kde.org"
FDO = "http://freedesktop.org"
ICON = "{http://www.freedesktop.org/standards/desktop-bookmarks}icon"


def update_places(path, folders):
    root = ET.parse(path, parser=ET.XMLParser(
        target=ET.TreeBuilder(insert_comments=True)
    )).getroot()
    bookmarks = {node.get("href"): node for node in root.findall("bookmark")}
    for folder, title, icon in folders:
        uri = folder.as_uri()
        bookmark = bookmarks.get(uri)
        if bookmark is None:
            bookmark = ET.SubElement(root, "bookmark", href=uri)
            ET.SubElement(bookmark, "title").text = title
            kde = ET.SubElement(ET.SubElement(bookmark, "info"), "metadata", owner=KDE)
            ET.SubElement(kde, "ID").text = f"imperial-databank/{uri}"
            ET.SubElement(kde, "OnlyInApp").text = "dolphin"
        info = bookmark.find("info")
        if info is None:
            info = ET.SubElement(bookmark, "info")
        metadata = info.find(f"metadata[@owner='{FDO}']")
        if metadata is None:
            metadata = ET.SubElement(info, "metadata", owner=FDO)
        icon_node = metadata.find(ICON)
        if icon_node is None:
            icon_node = ET.SubElement(metadata, ICON)
        icon_node.set("name", icon)
    ET.register_namespace("bookmark", ICON[1:].split("}")[0])
    ET.register_namespace("kdepriv", "http://www.kde.org/kdepriv")
    ET.register_namespace("mime", "http://www.freedesktop.org/standards/shared-mime-info")
    ET.indent(root, space=" ")
    with tempfile.NamedTemporaryFile(mode="wb", dir=path.parent, delete=False) as output:
        temporary = Path(output.name)
        try:
            output.write(b'<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE xbel>\n')
            ET.ElementTree(root).write(output, encoding="utf-8")
            output.write(b"\n")
            output.close()
            temporary.chmod(path.stat().st_mode & 0o777)
            temporary.replace(path)
        finally:
            temporary.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vault", action="append", type=Path, default=[])
    args = parser.parse_args()
    places = DATA / "user-places.xbel"
    if not places.is_file():
        parser.error("Open Dolphin once to create its Places file, then close it.")
    if subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", "dolphin"],
                      stdout=subprocess.DEVNULL).returncode == 0:
        parser.error("Close Dolphin before updating its Places and color scheme.")
    vaults = [path.expanduser().resolve() for path in args.vault]
    for vault in vaults:
        if not vault.is_dir():
            parser.error(f"Vault folder does not exist: {vault}")

    backups = STATE / "imperial-databank"
    backups.mkdir(parents=True, exist_ok=True)
    backup = Path(tempfile.mkdtemp(prefix="backup-", dir=backups))
    for path in (places, CONFIG / "dolphinrc"):
        if path.is_file():
            shutil.copy2(path, backup)
    schemes = DATA / "color-schemes"
    schemes.mkdir(parents=True, exist_ok=True)
    shutil.copy2(SOURCE / "ImperialDatabank.colors", schemes)
    icons = DATA / "icons/hicolor/scalable/places"
    icons.mkdir(parents=True, exist_ok=True)
    for icon in (SOURCE / "icons").glob("*.svg"):
        shutil.copy2(icon, icons)

    downloads = subprocess.run(["xdg-user-dir", "DOWNLOAD"], check=True,
                               capture_output=True, text=True).stdout.strip()
    folders = [(HOME / "Projects", "Projects", "imperial-projects")]
    if downloads and Path(downloads) != HOME:
        folders.append((Path(downloads), "Downloads", "imperial-cargo"))
    folders.extend((vault, vault.name.replace("_", " "), "imperial-vault") for vault in vaults)
    update_places(places, [item for item in folders if item[0].is_dir()])
    subprocess.run(["kwriteconfig6", "--file", "dolphinrc", "--group", "UiSettings",
                    "--key", "ColorScheme", "ImperialDatabank"], check=True)
    print(f"Imperial Databank enabled. Previous Dolphin settings: {backup}")


if __name__ == "__main__":
    main()
