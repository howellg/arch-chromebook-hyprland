extends Node3D

# Real 3D workspace selector. This process only lives while the picker is open.
# Hyprland is queried locally; no shell text from the UI is executed.
var world: VaultWorld
var hud: VaultHUD
var focus_id: int = 2
var active_workspace: int = 1
var records: Dictionary = {}
var mode: String = "vault"
var closed: bool = false
var target_look: Vector3 = Vector3(3.65, 1.35, 0)
var refresh_timer: Timer
var self_test: bool = false

func _ready() -> void:
    get_window().title = "Sith Holocron Vault"
    get_window().min_size = Vector2i(920, 600)
    self_test = "--self-test" in OS.get_cmdline_user_args()
    Engine.max_fps = 45

    world = VaultWorld.new()
    add_child(world)
    hud = VaultHUD.new()
    add_child(hud)
    for index in range(HyprBridge.WORKSPACES.size()):
        var key := "VAULT_PREVIEW_%d" % index
        hud.load_preview(OS.get_environment(key))
        OS.unset_environment(key)
    hud.select_requested.connect(_select)
    hud.activate_requested.connect(_activate)
    hud.mode_requested.connect(_set_mode)
    hud.close_requested.connect(_close)

    active_workspace = HyprBridge.get_current()
    focus_id = active_workspace
    _fetch_data()

    refresh_timer = Timer.new()
    refresh_timer.wait_time = 3.0
    refresh_timer.timeout.connect(_fetch_data)
    add_child(refresh_timer)
    refresh_timer.start()

    # A temporary visual test path; screenshots never enter the repository.
    if "--capture-preview" in OS.get_cmdline_user_args():
        get_tree().create_timer(2.0).timeout.connect(_capture_preview)
    elif "--capture-map" in OS.get_cmdline_user_args():
        _set_mode("map")
        get_tree().create_timer(2.0).timeout.connect(_capture_preview)
    elif "--capture-table" in OS.get_cmdline_user_args():
        _set_mode("table")
        get_tree().create_timer(2.0).timeout.connect(_capture_preview)

    if self_test:
        print("VAULT_TEST_READY: selected=", focus_id, " geometry=", world.vault_root.get_child_count())
        for m in ["map", "table", "vault"]:
            _set_mode(m)
            assert(world.mode == m)
        _select(3)
        assert(focus_id == 3)
        print("VAULT_TEST_PASS: live data fetched, modes and selection respond")
        get_tree().create_timer(1.4).timeout.connect(
            func() -> void: get_tree().quit()
        )

func _capture_preview() -> void:
    var image: Image = get_viewport().get_texture().get_image()
    var screenshot_path: String = OS.get_environment("HOME") + "/.local/state/sith-vault/" + mode + "-preview.png"
    var status: Error = image.save_png(screenshot_path)
    print("VAULT_CAPTURE: ", screenshot_path, " status=", status)
    get_tree().quit()

func _fetch_data() -> void:
    if closed:
        return
    records = HyprBridge.snapshot()
    world.update_occupancy(records)
    hud.display(focus_id, mode, records, active_workspace)

func _select(id: int) -> void:
    if id in HyprBridge.WORKSPACES:
        focus_id = id
        hud.display(focus_id, mode, records, active_workspace)

func _set_mode(next_mode: String) -> void:
    if not next_mode in ["vault", "map", "table"]:
        return
    mode = next_mode
    world.set_mode(mode)
    hud.display(focus_id, mode, records, active_workspace)

func _activate(id: int) -> void:
    if self_test or closed:
        return
    if not id in HyprBridge.WORKSPACES:
        return
    closed = true
    # Keep current focus when Hyprland is unavailable instead of guessing.
    var switched: bool = HyprBridge.switch_to(id)
    if switched:
        HyprBridge.remember(id)
        if id != active_workspace:
            OS.create_process(OS.get_environment("HOME").path_join(".local/bin/hypr-galactic-cue"), ["workspace"])
    else:
        push_warning("Hyprland refused workspace switch: %d" % id)
    get_tree().quit()

func _close() -> void:
    if closed:
        return
    closed = true
    get_tree().quit()

func _process(delta: float) -> void:
    if world == null:
        return
    world.update_scene(delta, focus_id)
    var base_camera: Vector3
    match mode:
        "vault":
            base_camera = Vector3(3.7, 10.2, 18.9)
        "map":
            base_camera = Vector3(3.7, 13.2, 19.4)
        _:
            base_camera = Vector3(3.7, 12.1, 18.6)
    var focus_point: Vector3 = Vector3.ZERO
    var idx: int = HyprBridge.WORKSPACES.find(focus_id)
    if idx >= 0 and mode != "table":
        focus_point = VaultWorld.STATIONS[idx] * .13
    var camera_target: Vector3 = base_camera + Vector3(focus_point.x * .24, 0, 0)
    world.camera.position = world.camera.position.lerp(camera_target, minf(1.0, delta * 2.4))
    target_look = target_look.lerp(Vector3(3.65 + focus_point.x * .30, 1.35, focus_point.z),
        minf(1.0, delta * 2.6))
    world.camera.look_at(target_look)

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey:
        return
    if not event.pressed or event.echo:
        return
    var id: int = -1
    match event.keycode:
        KEY_ESCAPE:
            _close()
        KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
            _activate(focus_id)
        KEY_1, KEY_KP_1: id = 1
        KEY_2, KEY_KP_2: id = 2
        KEY_3, KEY_KP_3: id = 3
        KEY_4, KEY_KP_4: id = 4
        KEY_5, KEY_KP_5: id = 5
        KEY_9, KEY_KP_9: id = 9
        KEY_S: _set_mode("vault")
        KEY_G: _set_mode("map")
        KEY_I: _set_mode("table")
        KEY_LEFT, KEY_UP:
            var previous: int = HyprBridge.WORKSPACES.find(focus_id) - 1
            id = HyprBridge.WORKSPACES[posmod(previous, 6)]
        KEY_RIGHT, KEY_DOWN:
            var next: int = HyprBridge.WORKSPACES.find(focus_id) + 1
            id = HyprBridge.WORKSPACES[posmod(next, 6)]
    if id >= 0:
        _select(id)
    get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
    var pointer: Vector2
    if event is InputEventMouseMotion:
        pointer = event.position
        var hovered: int = _hit_node(pointer)
        if hovered != -1 and hovered != focus_id:
            _select(hovered)
    elif event is InputEventMouseButton:
        if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
            return
        pointer = event.position
        var hovered: int = _hit_node(pointer)
        if hovered >= 0:
            _activate(hovered)
            get_viewport().set_input_as_handled()

func _hit_node(pointer: Vector2) -> int:
    var nearest: float = 65.0
    var result: int = -1
    for i in range(HyprBridge.WORKSPACES.size()):
        var pt: Vector3 = VaultWorld.STATIONS[i]
        if mode == "map":
            pt = pt * 1.18 + Vector3(0, 1.7, 0)
        else:
            pt = world.sector_centers[HyprBridge.WORKSPACES[i]] if mode == "table" else world.gems[HyprBridge.WORKSPACES[i]].global_position
        var camera_pos: Vector2 = world.camera.unproject_position(pt)
        var dist: float = pointer.distance_to(camera_pos)
        if dist < nearest:
            nearest = dist
            result = HyprBridge.WORKSPACES[i]
    return result
