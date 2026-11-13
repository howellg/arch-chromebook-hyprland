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
var application: Label
var count_label: Label
var windows_label: Label
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
    node.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
    _place(panel, 850, 136, 318, 468)
    var marker := Color("#8da0b7")
    _text(panel, "ACTIVE ARCHIVE NODE", 14, marker, Vector2(18, 18), Vector2(280, 23))
    number = _text(panel, "02", 48, focus_color, Vector2(18, 50), Vector2(120, 65))
    name_label = _text(panel, "SITH ARCHIVES", 24, Color("#f7e4e9"),
        Vector2(20, 119), Vector2(282, 38))
    planet = _text(panel, "KORRIBAN  /  LEGENDS SECTOR", 14,
        Color("#d6a2aa"), Vector2(20, 163), Vector2(282, 26))
    var rule := ColorRect.new()
    rule.color = Color("#5b3c4c")
    rule.position = Vector2(20, 203)
    rule.size = Vector2(276, 2)
    panel.add_child(rule)
    _text(panel, "ASSIGNED SYSTEM", 13, marker, Vector2(20, 219), Vector2(267, 25))
    application = _text(panel, "Kitty / Terminal", 18, Color("#e0e5ec"),
        Vector2(20, 247), Vector2(284, 28))
    _text(panel, "LIVE WORKSPACE DATA", 13, marker,
        Vector2(20, 294), Vector2(268, 25))
    count_label = _text(panel, "SCANNING...", 15, Color("#e7c3c9"),
        Vector2(20, 321), Vector2(276, 27))
    windows_label = _text(panel, "Checking Hyprland...", 13,
        Color("#bbc7d5"), Vector2(20, 350), Vector2(275, 76))
    windows_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label = _text(panel, "SELECT AN ARCHIVE TO VIEW DETAILS", 12,
        Color("#7fe3e0"), Vector2(20, 430), Vector2(280, 22))

func _button(parent: Control, text: String, x: float, y: float, w: float, h: float, action: Callable) -> Button:
    var b := Button.new()
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
    _place(strip, 28, 626, 1140, 77)
    for idx in range(HyprBridge.WORKSPACES.size()):
        var id: int = HyprBridge.WORKSPACES[idx]
        var label: String = "%02d  %s" % [id, str(HyprBridge.NAMES[id])]
        var b: Button = _button(strip, label, 11 + idx * 187, 14, 178, 47,
            func() -> void: activate_requested.emit(id))
        b.mouse_entered.connect(func() -> void: select_requested.emit(id))
        sector_buttons[id] = b

func _build_bottom_bar() -> void:
    var info := Panel.new()
    info.add_theme_stylebox_override("panel", _skin(Color("#455061"), Color(0.03, 0.042, 0.064, .93)))
    _place(info, 28, 712, 1140, 36)
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
    application.text = str(HyprBridge.APPS[selected])
    var entry: Dictionary = records.get(selected, {"count": 0, "windows": []})
    var count: int = int(entry.get("count", 0))
    count_label.text = "%d ACTIVE WINDOW%s" % [count, "" if count == 1 else "S"]
    var titles: Array = entry.get("windows", [])
    if titles.is_empty():
        windows_label.text = "EMPTY SECTOR\nReady for new programs"
    else:
        var strings: Array[String] = []
        for i in range(mini(titles.size(), 3)):
            var value: String = str(titles[i])
            strings.append("• " + value.substr(0, 38))
        if titles.size() > 3:
            strings.append("• +%d more" % (titles.size() - 3))
        windows_label.text = "\n".join(strings)
    status_label.text = "CURRENT DESKTOP" if current == selected else "PRESS ENTER TO ACCESS"
    heading.text = {"vault": "SITH  /  HOLOCRON VAULT", "map": "RAKATAN  /  STAR MAP",
        "table": "IMPERIAL  /  HOLOTABLE"}.get(mode, "SITH  /  HOLOCRON VAULT")
    subheading.text = "KORRIBAN ARCHIVES    •    %s NAVIGATION" % {
        "vault": "SITH", "map": "RAKATAN", "table": "IMPERIAL"
    }.get(mode, "SITH")
    for id in sector_buttons:
        var button: Button = sector_buttons[id]
        var tint: Color = HyprBridge.TINTS[id]
        var engaged: bool = int(id) == selected
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
