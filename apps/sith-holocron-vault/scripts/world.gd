class_name VaultWorld
extends Node3D

# Geometry and lighting are fully procedural: no image assets or imported models.
const IDS: Array[int] = [1, 2, 3, 4, 5, 9]
const STATIONS: Array[Vector3] = [
    Vector3(-5.15, 0.0, -0.10), Vector3(-2.65, 0.0, -4.15),
    Vector3(2.65, 0.0, -4.15), Vector3(5.15, 0.0, -0.10),
    Vector3(3.25, 0.0, 4.2), Vector3(-3.25, 0.0, 4.2)
]
var vault_root: Node3D
var map_root: Node3D
var tactical_root: Node3D
var camera: Camera3D
var gems: Dictionary = {}
var floating_parts: Dictionary = {}
var core_rings: Array[Node3D] = []
var mode: String = "vault"
var active_id: int = 2
var clock: float = 0.0
var metal: StandardMaterial3D
var basalt: StandardMaterial3D
var basalt_light: StandardMaterial3D
var blackstone: StandardMaterial3D
var gold: StandardMaterial3D
var red_glow: StandardMaterial3D
var cyan_glow: StandardMaterial3D

func _ready() -> void:
    metal = _mat("#252936", 0.80, 0.28)
    basalt = _mat("#1b1b27", 0.15, 0.90)
    basalt_light = _mat("#33303a", 0.20, 0.82)
    blackstone = _mat("#0d111a", 0.55, 0.7)
    gold = _mat("#8c6555", 0.65, 0.42)
    red_glow = _mat("#771d31", 0.25, 0.3, "#de445e", 1.6)
    cyan_glow = _mat("#236b7a", 0.35, 0.22, "#66d5e5", 1.25)
    _setup_scene()
    vault_root = Node3D.new()
    vault_root.name = "VaultChamber"
    add_child(vault_root)
    _build_vault()
    map_root = Node3D.new()
    map_root.name = "GalacticMap"
    add_child(map_root)
    _build_galaxy()
    tactical_root = Node3D.new()
    tactical_root.name = "ImperialHolotable"
    add_child(tactical_root)
    _build_tactical()
    set_mode("vault")

func _mat(base: String, metallic: float = 0.0, roughness: float = 0.8, emission: String = "", energy: float = 1.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(base)
    m.metallic = metallic
    m.roughness = roughness
    if not emission.is_empty():
        m.emission_enabled = true
        m.emission = Color(emission)
        m.emission_energy_multiplier = energy
    return m

func _shape(parent: Node3D, geom: Mesh, mat: Material, pos: Vector3, size: Vector3 = Vector3.ONE) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.mesh = geom
    part.material_override = mat
    part.position = pos
    part.scale = size
    parent.add_child(part)
    return part

func _box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
    var m := BoxMesh.new()
    m.size = size
    return _shape(parent, m, mat, pos)

func _cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, mat: Material, sides: int = 24) -> MeshInstance3D:
    var m := CylinderMesh.new()
    m.top_radius = radius
    m.bottom_radius = radius
    m.height = height
    m.radial_segments = sides
    return _shape(parent, m, mat, pos)

func _torus(parent: Node3D, pos: Vector3, major_radius: float, tube: float, mat: Material) -> MeshInstance3D:
    var m := TorusMesh.new()
    m.inner_radius = maxf(0.01, major_radius - tube)
    m.outer_radius = major_radius + tube
    m.rings = 52
    m.ring_segments = 8
    return _shape(parent, m, mat, pos)

func _rod(parent: Node3D, start: Vector3, end: Vector3, radius: float, mat: Material) -> MeshInstance3D:
    var delta: Vector3 = end - start
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = delta.length()
    mesh.radial_segments = 6
    var item: MeshInstance3D = _shape(parent, mesh, mat, (start + end) * 0.5)
    item.quaternion = Quaternion(Vector3.UP, delta.normalized())
    return item

func _label(parent: Node3D, value: String, mat_color: Color, at: Vector3, px: int = 32) -> Label3D:
    var l := Label3D.new()
    l.text = value
    l.position = at
    l.font_size = px
    l.pixel_size = 0.007
    l.modulate = mat_color
    l.outline_size = 6
    l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    l.no_depth_test = true
    parent.add_child(l)
    return l

func _setup_scene() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_COLOR
    e.background_color = Color("#090d16")
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color("#526079")
    e.ambient_light_energy = 0.68
    e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.environment = e
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.light_color = Color("#9da0b6")
    sun.light_energy = 0.85
    sun.rotation_degrees = Vector3(-45, 30, 0)
    add_child(sun)

    for s in [Vector3(-5, 6, -4), Vector3(5, 6, 3), Vector3(0, 7, 0)]:
        var light := OmniLight3D.new()
        light.position = s
        light.light_color = Color("#bd3b50") if s.x <= 0 else Color("#528fa7")
        light.light_energy = 1.15
        light.omni_range = 13.0
        light.shadow_enabled = false
        add_child(light)

    camera = Camera3D.new()
    camera.fov = 51.0
    camera.near = 0.1
    camera.far = 85.0
    camera.position = Vector3(2.4, 8.6, 18.3)
    camera.current = true
    add_child(camera)
    camera.look_at(Vector3(2.35, 1.65, 0))

func _build_vault() -> void:
    _box(vault_root, Vector3(0, -0.55, 0), Vector3(22, 0.8, 22), basalt)
    _box(vault_root, Vector3(0, -0.135, 0), Vector3(20.6, 0.11, 20.6), blackstone)
    # Individual stone floor pavers with slight height variation and incised seams.
    for row in range(-8, 9):
        for column in range(-8, 9):
            if (row * row + column * column) > 85:
                continue
            var height: float = 0.012 * float((column * 7 + row * 13) % 3)
            _box(vault_root, Vector3(float(column) * 1.12, -0.056 + height, float(row) * 1.12),
                Vector3(1.09, 0.058, 1.09), basalt if (row + column) % 4 else basalt_light)
    for radius in [7.4, 5.95, 2.95]:
        _torus(vault_root, Vector3(0, 0.012, 0), radius, 0.038, gold)
    for angle in range(16):
        var theta: float = float(angle) * TAU / 16.0
        # Front columns blocked most of the workspace selector in perspective.
        # Keep the monumental architecture as a backdrop and side walls.
        if sin(theta) > 0.25:
            continue
        var radial := Vector3(cos(theta), 0, sin(theta))
        var center: Vector3 = radial * 9.5
        _build_column(vault_root, center)
        # recessed crimson runes between massive pillars
        var outer: Vector3 = radial * 8.9
        _box(vault_root, outer + Vector3(0, 0.1, 0), Vector3(0.18, 0.05, 0.58), red_glow)
    for i in range(6):
        var at: Vector3 = STATIONS[i]
        var slot: int = IDS[i]
        var palette: Color = HyprBridge.TINTS[slot]
        var tint: StandardMaterial3D = _mat("#1f1d27", 0.45, 0.4, "#" + palette.to_html(false), 1.7)
        _cylinder(vault_root, at + Vector3(0, 0.22, 0), 1.06, 0.45, basalt_light)
        _cylinder(vault_root, at + Vector3(0, 0.49, 0), 0.84, 0.13, metal)
        _torus(vault_root, at + Vector3(0, 0.58, 0), 0.78, 0.055, tint)
        _cylinder(vault_root, at + Vector3(0, 1.15, 0), 0.35, 1.13, blackstone)
        _cylinder(vault_root, at + Vector3(0, 1.73, 0), 0.48, 0.12, metal)
        var gem_root := Node3D.new()
        gem_root.position = at + Vector3(0, 2.65, 0)
        gem_root.name = "Holocron%02d" % slot
        vault_root.add_child(gem_root)
        _build_holocron(gem_root, palette)
        gems[slot] = gem_root
        floating_parts[slot] = tint
        _label(vault_root, "%02d / %s" % [slot, str(HyprBridge.NAMES[slot])],
            palette, at + Vector3(0, 3.75, 0), 30)

    _cylinder(vault_root, Vector3(0, 0.36, 0), 2.04, 0.75, basalt_light)
    _cylinder(vault_root, Vector3(0, 0.79, 0), 1.72, 0.18, metal)
    _torus(vault_root, Vector3(0, 0.94, 0), 1.45, 0.09, red_glow)
    _cylinder(vault_root, Vector3(0, 1.35, 0), 1.06, 1.0, blackstone)
    _cylinder(vault_root, Vector3(0, 1.96, 0), 0.82, 0.20, metal)
    _build_central_core(vault_root)
    for angle in range(8):
        var theta: float = float(angle) * TAU / 8.0
        var p: Vector3 = Vector3(cos(theta) * 2.45, 0.03, sin(theta) * 2.45)
        _rod(vault_root, p, p + Vector3(cos(theta) * .35, .22, sin(theta) * .35), .045, red_glow)

func _build_column(parent: Node3D, pos: Vector3) -> void:
    _box(parent, pos + Vector3(0, 0.62, 0), Vector3(1.2, 1.25, 1.2), blackstone)
    _box(parent, pos + Vector3(0, 2.75, 0), Vector3(0.74, 3.1, 0.74), basalt_light)
    _box(parent, pos + Vector3(0, 4.47, 0), Vector3(1.12, 0.30, 1.12), blackstone)
    _box(parent, pos + Vector3(0, 5.95, 0), Vector3(0.9, 2.6, 0.9), basalt)
    _box(parent, pos + Vector3(0, 3.65, 0.39), Vector3(.17, 1.5, .11), gold)

func _build_holocron(parent: Node3D, palette: Color) -> void:
    var tint: String = "#" + palette.to_html(false)
    var gem_mat: StandardMaterial3D = _mat("#32252b", 0.50, 0.24, tint, 1.4)
    var lines: StandardMaterial3D = _mat("#9f3949", 0.5, 0.23, tint, 2.2)
    var top := Vector3(0, .72, 0)
    var bottom := Vector3(0, -.72, 0)
    var base: Array[Vector3] = [
        Vector3(-.64, 0, -.64), Vector3(.64, 0, -.64),
        Vector3(.64, 0, .64), Vector3(-.64, 0, .64)
    ]
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(4):
        var j: int = (i + 1) % 4
        for pt in [top, base[i], base[j]]:
            surface.add_vertex(pt)
        for pt in [bottom, base[j], base[i]]:
            surface.add_vertex(pt)
    surface.generate_normals()
    _shape(parent, surface.commit(), gem_mat, Vector3.ZERO)
    for i in range(4):
        _rod(parent, top, base[i], .035, lines)
        _rod(parent, bottom, base[i], .035, lines)
        _rod(parent, base[i], base[(i + 1) % 4], .035, lines)
    _torus(parent, Vector3.ZERO, .92, .025, lines)
    _cylinder(parent, Vector3.ZERO, .10, 1.10, lines, 8)
    var dot := OmniLight3D.new()
    dot.light_color = palette
    dot.light_energy = 0.22
    dot.omni_range = 2.4
    parent.add_child(dot)

func _build_central_core(parent: Node3D) -> void:
    var hub := Node3D.new()
    hub.position = Vector3(0, 3.1, 0)
    parent.add_child(hub)
    _build_holocron(hub, Color("#ed526c"))
    hub.scale = Vector3.ONE * 0.92
    core_rings.append(hub)
    for axis in range(3):
        var ring := Node3D.new()
        ring.position = Vector3(0, 3.1, 0)
        ring.rotation_degrees = Vector3(65 if axis == 0 else 0, axis * 60, 65 if axis == 2 else 0)
        parent.add_child(ring)
        _torus(ring, Vector3.ZERO, 1.55 + axis * .20, .05, red_glow if axis != 1 else cyan_glow)
        core_rings.append(ring)

func _build_galaxy() -> void:
    _cylinder(map_root, Vector3(0, -.3, 0), 9.0, .7, blackstone, 64)
    _torus(map_root, Vector3(0, .12, 0), 7.0, .035, cyan_glow)
    _torus(map_root, Vector3(0, .12, 0), 4.6, .035, cyan_glow)
    _cylinder(map_root, Vector3(0, .38, 0), 1.55, .25, metal)
    _torus(map_root, Vector3(0, 0.6, 0), 1.22, .08, cyan_glow)
    _label(map_root, "ANCIENT STAR MAP", Color("#83e0ef"), Vector3(0, 2.1, 0), 42)
    for i in range(6):
        var n: int = IDS[i]
        var pos: Vector3 = STATIONS[i] * 1.18 + Vector3(0, 1.7, 0)
        var planet_mat: StandardMaterial3D = _mat("#263948", .35, .40,
            "#" + HyprBridge.TINTS[n].to_html(false), 1.2)
        var sphere := SphereMesh.new()
        sphere.radius = 0.48 if n != 9 else 0.62
        sphere.height = sphere.radius * 2.0
        _shape(map_root, sphere, planet_mat, pos)
        _torus(map_root, pos + Vector3(0, -.55, 0), 0.72, .035, cyan_glow)
        _rod(map_root, Vector3(0, .65, 0), pos, .013, cyan_glow)
        _label(map_root, "%02d / %s" % [n, str(HyprBridge.PLANETS[n])],
            HyprBridge.TINTS[n], pos + Vector3(0, 1.12, 0), 34)
        if i == 0 or i == 3:
            _cylinder(map_root, pos + Vector3(0, -.6, 0), .3, .20, metal)

func _build_tactical() -> void:
    _box(tactical_root, Vector3(0, -.40, 0), Vector3(18.2, .7, 17.5), basalt)
    _cylinder(tactical_root, Vector3(0, .2, 0), 7.8, .2, metal, 64)
    _torus(tactical_root, Vector3(0, .33, 0), 7.32, .05, red_glow)
    _label(tactical_root, "IMPERIAL FLEET TACTICAL COMMAND", Color("#ef9c9c"), Vector3(0, 3.8, -6.3), 46)
    for i in range(6):
        var n: int = IDS[i]
        var x: float = -4.9 + float(i % 3) * 4.9
        var z: float = -2.3 + float(i / 3) * 4.6
        var at := Vector3(x, 0.65, z)
        _box(tactical_root, at, Vector3(3.5, .60, 2.8), basalt_light)
        _box(tactical_root, at + Vector3(0, .36, 0), Vector3(3.36, .045, 2.64),
            red_glow if n == 2 else cyan_glow)
        _label(tactical_root, "%02d / %s" % [n, str(HyprBridge.NAMES[n])],
            HyprBridge.TINTS[n], at + Vector3(0, 1.30, 0), 30)
        for bar in range(7):
            _box(tactical_root, at + Vector3(-1.35 + bar * .43, .50, .75),
                Vector3(.20, .13, .11), gold if bar % 3 == 0 else blackstone)

func set_mode(value: String) -> void:
    mode = value
    vault_root.visible = value == "vault"
    map_root.visible = value == "map"
    tactical_root.visible = value == "table"

func update_scene(delta: float, focus: int) -> void:
    clock += delta
    active_id = focus
    if mode == "vault":
        for i in range(6):
            var slot: int = IDS[i]
            var item: Node3D = gems[slot]
            var base: Vector3 = STATIONS[i]
            var desired_height: float = 2.65 + sin(clock * 1.0 + float(i)) * .11
            if slot == focus:
                desired_height += .45
            item.position.y = lerpf(item.position.y, desired_height, minf(1, delta * 7.0))
            item.rotation.y += delta * (0.42 if slot == focus else 0.11)
            var desired_scale: float = 1.16 if slot == focus else .94
            item.scale = item.scale.lerp(Vector3.ONE * desired_scale, minf(1, delta * 6.0))
        for i in range(core_rings.size()):
            core_rings[i].rotate_y(delta * (.15 + float(i) * .07))
