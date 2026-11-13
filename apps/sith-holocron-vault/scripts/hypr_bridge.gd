class_name HyprBridge
extends RefCounted

const WORKSPACES: Array[int] = [1, 2, 3, 4, 5, 9]
const NAMES: Dictionary = {
    1: "CITADEL", 2: "SITH ARCHIVES", 3: "RAKATAN FORGE",
    4: "HOLONET", 5: "IMPERIAL DATABANK", 9: "COMMAND RELAY"
}
const APPS: Dictionary = {
    1: "Firefox / Web", 2: "Kitty / Terminal", 3: "VS Code / Development",
    4: "Discord / Comms", 5: "MySQL / Databases", 9: "Desktop Commander"
}
const PLANETS: Dictionary = {
    1: "CORUSCANT", 2: "KORRIBAN", 3: "LEHON",
    4: "CORELLIA", 5: "BYSS", 9: "DEATH STAR"
}
const TINTS: Dictionary = {
    1: Color("#e57378"), 2: Color("#ed405d"), 3: Color("#64d5df"),
    4: Color("#92b8e3"), 5: Color("#d9ad67"), 9: Color("#bec1d9")
}

static func _json(args: PackedStringArray) -> Variant:
    var output: Array = []
    var status: int = OS.execute("hyprctl", args, output, true)
    if status != 0 or output.is_empty():
        return null
    return JSON.parse_string(str(output[0]))

static func get_current() -> int:
    var data: Variant = _json(PackedStringArray(["activeworkspace", "-j"]))
    if data is Dictionary:
        var found: int = int(data.get("id", 1))
        return found if found in WORKSPACES else 1
    return 1

static func snapshot() -> Dictionary:
    var records: Dictionary = {}
    for n in WORKSPACES:
        records[n] = {"count": 0, "windows": [], "title": ""}
    var clients: Variant = _json(PackedStringArray(["clients", "-j"]))
    if clients is Array:
        for c in clients:
            if not c is Dictionary:
                continue
            var location: Variant = c.get("workspace", {})
            if not location is Dictionary:
                continue
            var ws: int = int(location.get("id", -1))
            if not records.has(ws):
                continue
            var cls: String = str(c.get("class", "Application"))
            var title: String = str(c.get("title", "")).strip_edges()
            if cls.to_lower().contains("godot") or title.begins_with("Sith Holocron Vault"):
                continue
            var item: Dictionary = records[ws]
            item["count"] = int(item["count"]) + 1
            var display: String = title if not title.is_empty() else cls
            if str(item["title"]).is_empty():
                item["title"] = display
            var listing: Array = item["windows"]
            listing.append(display)
    return records

static func switch_to(workspace_id: int) -> bool:
    if not workspace_id in WORKSPACES:
        return false
    var expression: String = "hl.dsp.focus({ workspace = %d })" % workspace_id
    var output: Array = []
    return OS.execute("hyprctl", PackedStringArray(["dispatch", expression]), output, true) == 0
