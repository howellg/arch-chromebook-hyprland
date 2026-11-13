class_name VaultHUD
extends CanvasLayer

signal select_requested(workspace: int)
signal activate_requested(workspace: int)
signal mode_requested(mode: String)
signal close_requested
signal settings_requested

var root: Control
var heading: Label
var subheading: Label
var mode_labels: Dictionary = {}
var number: Label
var name_label: Label
var planet: Label
var count_label: Label
var rows: Array[Label] = []
var row_icons: Array[Label] = []
var thumbnail: TextureRect
var thumbnail_hint: Label
var preview_address := ""
var preview_texture: Texture2D
var status_label: Label
var sector_buttons: Dictionary = {}
var focus_color: Color = Color("#ed405d")
var modes: Array[String] = ["vault", "map", "table"]
var last_mode: String = ""

func _ready() -> void:
    root = Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root)
    _build_heading()
    _build_data_panel()
    _build_sector_buttons()
    _build_bottom_bar()

func _skin(color: Color, backdrop: Color, thickness: int = 1) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = backdrop
    s.border_color = color
    s.set_border_width_all(thickness)
    s.set_corner_radius_all(4)
    s.content_margin_left = 10
    s.content_margin_right = 10
    s.content_margin_top = 7
    s.content_margin_bottom = 7
    return s

func _place(node: Control, x: float, y: float, w: float, h: float) -> void:
    node.position = Vector2(x, y)
    node.size = Vector2(w, h)
    node.mouse_filter = Control.MOUSE_FILTER_STOP
    root.add_child(node)

func _text(parent: Control, message: String, font_size: int, color: Color, pos: Vector2, area: Vector2) -> Label:
    var label := Label.new()
    label.text = message
    label.position = pos
    label.size = area
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _build_heading() -> void:
    var frame := Panel.new()
    frame.add_theme_stylebox_override("panel", _skin(Color("#743943"), Color(0.04, 0.052, 0.08, .91), 2))
    _place(frame, 28, 18, 610, 94)
    heading = _text(frame, "SITH  /  HOLOCRON VAULT", 28, Color("#f0d7db"),
        Vector2(20, 14), Vector2(565, 34))
    subheading = _text(frame, "KORRIBAN ARCHIVES   •   ANCIENT NAVIGATION ARRAY", 14, Color("#d37985"),
        Vector2(21, 54), Vector2(560, 23))

func _build_data_panel() -> void:
    var panel := Panel.new()
    panel.add_theme_stylebox_override("panel", _skin(Color("#9c394d"), Color(0.045, 0.060, 0.087, .93), 2))
    _place(panel, 888, 136, 284, 468)
    panel.set_anchors_preset(Control.PRESET_TOP_RIGHT, true)
    panel.offset_left = -312
    panel.offset_right = -28
    var marker := Color("#8da0b7")
    _text(panel, "WORKSPACE DOSSIER", 13, marker, Vector2(18, 14), Vector2(247, 24))
    number = _text(panel, "", 30, focus_color, Vector2(18, 44), Vector2(55, 42))
    name_label = _text(panel, "", 16, Color("#f7e4e9"), Vector2(77, 45), Vector2(189, 34))
    planet = _text(panel, "", 12, Color("#d6a2aa"), Vector2(20, 88), Vector2(244, 22))

    var frame := Panel.new()
    frame.position = Vector2(20, 119)
    frame.size = Vector2(244, 137)
    frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame.add_theme_stylebox_override("panel", _skin(Color("#583a51"), Color("#10131e")))
    panel.add_child(frame)
    thumbnail = TextureRect.new()
    thumbnail.position = Vector2(2, 2)
    thumbnail.size = Vector2(240, 133)
    thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    thumbnail.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame.add_child(thumbnail)
    thumbnail_hint = _text(frame, "", 12, marker, Vector2(0, 0), frame.size)
    thumbnail_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    thumbnail_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    count_label = _text(panel, "", 14, Color("#e7c3c9"), Vector2(20, 266), Vector2(244, 24))
    var icon_font := SystemFont.new()
    icon_font.font_names = PackedStringArray(["JetBrainsMono Nerd Font"])
    for i in range(4):
        var y: float = 299 + i * 27
        var icon := _text(panel, "", 15, marker, Vector2(20, y), Vector2(26, 24))
        icon.add_theme_font_override("font", icon_font)
        row_icons.append(icon)
        var title := _text(panel, "", 13, Color("#bbc7d5"), Vector2(47, y), Vector2(216, 24))
        title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
        rows.append(title)
    status_label = _text(panel, "", 12, Color("#7fe5e0"), Vector2(20, 430), Vector2(244, 22))

func load_preview(payload: String) -> void:
    var parts := payload.split(":", false, 1)
    if parts.size() != 2:
        return
    var image := Image.new()
    if image.load_jpg_from_buffer(Marshalls.base64_to_raw(parts[1])) == OK:
        preview_address = parts[0]
        preview_texture = ImageTexture.create_from_image(image)

func _app_icon(app_class: String) -> String:
    var name := app_class.to_lower()
    if name.contains("firefox") or name.contains("chromium"):
        return "󰈹"
    if name.contains("kitty") or name.contains("terminal"):
        return ""
    if name.contains("code"):
        return "󰨞"
    if name.contains("discord"):
        return "󰙯"
    if name.contains("dolphin") or name.contains("thunar"):
        return ""
    return "󰖲"

func _button(parent: Control, text: String, x: float, y: float, w: float, h: float, action: Callable) -> Button:
    var b := Button.new()
    b.clip_text = true
    b.text = text
    b.position = Vector2(x, y)
    b.size = Vector2(w, h)
    b.mouse_filter = Control.MOUSE_FILTER_STOP
    b.focus_mode = Control.FOCUS_NONE
    b.add_theme_font_size_override("font_size", 15)
    var inactive: StyleBoxFlat = _skin(Color("#5b4554"), Color(0.055, 0.065, 0.09, .9))
    var hover: StyleBoxFlat = _skin(Color("#ed6273"), Color("#35212e"), 2)
    b.add_theme_stylebox_override("normal", inactive)
    b.add_theme_stylebox_override("hover", hover)
    b.add_theme_stylebox_override("pressed", hover)
    b.add_theme_color_override("font_color", Color("#e5cbd1"))
    b.pressed.connect(action)
    parent.add_child(b)
    return b

func _build_sector_buttons() -> void:
    var strip := Panel.new()
    strip.add_theme_stylebox_override("panel", _skin(Color("#3b3b4a"), Color(0.04, 0.055, 0.080, .93)))
    _place(strip, 28, 622, 1144, 77)
    strip.set_anchors_preset(Control.PRESET_BOTTOM_LEFT, true)
    strip.offset_top = -128
    strip.offset_bottom = -51
    for idx in range(HyprBridge.WORKSPACES.size()):
        var id: int = HyprBridge.WORKSPACES[idx]
        var label: String = "%02d  %s" % [id, HyprBridge.NAMES[id]]
        var b: Button = _button(strip, label, 11 + idx * 187, 14, 178, 47,
            func() -> void: activate_requested.emit(id))
        b.add_theme_font_size_override("font_size", 12)
        b.mouse_entered.connect(func() -> void: select_requested.emit(id))
        sector_buttons[id] = b

func _build_bottom_bar() -> void:
    var info := Panel.new()
    info.add_theme_stylebox_override("panel", _skin(Color("#455061"), Color(0.03, 0.042, 0.064, .93)))
    _place(info, 28, 708, 1144, 36)
    info.set_anchors_preset(Control.PRESET_BOTTOM_LEFT, true)
    info.offset_top = -42
    info.offset_bottom = -6
    _text(info, "← → ↑ ↓  FOCUS     1–5 / 9  SELECT     ENTER  ACCESS     ESC  EXIT",
        12, Color("#c2d0d8"), Vector2(12, 6), Vector2(760, 26))
    var views := ["S  VAULT", "G  STAR MAP", "I  HOLOTABLE"]
    for i in range(3):
        var view_name: String = modes[i]
        var b: Button = _button(info, views[i], 754 + i * 125, 3, 121, 28,
            func() -> void: mode_requested.emit(view_name))
        b.add_theme_font_size_override("font_size", 12)
        mode_labels[view_name] = b

func display(selected: int, mode: String, records: Dictionary, current: int) -> void:
    if not HyprBridge.WORKSPACES.has(selected):
        return
    focus_color = HyprBridge.TINTS[selected]
    number.text = "%02d" % selected
    number.add_theme_color_override("font_color", focus_color)
    name_label.text = str(HyprBridge.NAMES[selected])
    planet.text = str(HyprBridge.PLANETS[selected]) + "  /  ARCHIVE SECTOR"
    var entry: Dictionary = records.get(selected, {})
    var clients: Array = entry.get("clients", [])
    var count := clients.size()
    count_label.text = "NO OPEN WINDOWS" if count == 0 else "%d OPEN WINDOW%s" % [count, "" if count == 1 else "S"]
    thumbnail.texture = null
    thumbnail_hint.text = "EMPTY SECTOR" if count == 0 else "NO VISIBLE PREVIEW"
    for client in clients:
        if client["address"] == preview_address and preview_texture:
            thumbnail.texture = preview_texture
            thumbnail_hint.text = ""
            break
    for i in range(rows.size()):
        rows[i].text = ""
        row_icons[i].text = ""
        if i >= count:
            continue
        if i == rows.size() - 1 and count > rows.size():
            rows[i].text = "+%d more windows" % (count - i)
        else:
            rows[i].text = clients[i]["title"]
            row_icons[i].text = _app_icon(clients[i]["class"])
    status_label.text = "CURRENT DESKTOP" if current == selected else "PRESS ENTER TO ACCESS"
    heading.text = {"vault": "SITH  /  HOLOCRON VAULT", "map": "RAKATAN  /  STAR MAP",
        "table": "IMPERIAL  /  HOLOTABLE"}.get(mode, "SITH  /  HOLOCRON VAULT")
    subheading.text = {
        "vault": "KORRIBAN ARCHIVES",
        "map": "HYPERSPACE ROUTES",
        "table": "LIVE WINDOWS BY SECTOR"
    }.get(mode, "")
    for id in sector_buttons:
        var button: Button = sector_buttons[id]
        var tint: Color = HyprBridge.TINTS[id]
        var engaged: bool = int(id) == selected
        var short_name: String = "DATABANK" if id == 5 and mode == "table" else HyprBridge.NAMES[id]
        button.text = "%02d  %s" % [id, short_name]
        if mode == "table":
            button.text += " · %d" % int(records.get(id, {}).get("count", 0))
        button.add_theme_stylebox_override("normal",
            _skin(tint if engaged else Color("#565067"),
                Color(tint.r * .25, tint.g * .20, tint.b * .24, .97) if engaged else Color(0.055, 0.066, .087, .92),
                2 if engaged else 1))
        button.add_theme_color_override("font_color", tint if engaged else Color("#b9c0ce"))
    if last_mode != mode:
        for m in mode_labels:
            var b: Button = mode_labels[m]
            b.add_theme_color_override("font_color",
                Color("#ef8292") if str(m) == mode else Color("#b2bdcd"))
        last_mode = mode
