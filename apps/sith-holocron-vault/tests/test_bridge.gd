extends SceneTree

func _initialize() -> void:
    var ids: Array[int] = HyprBridge.WORKSPACES
    assert(ids == [1, 2, 3, 4, 5, 9])
    var records: Dictionary = HyprBridge.snapshot()
    for id in ids:
        assert(records.has(id))
        assert(records[id] is Dictionary)
        assert(records[id].has("count"))
        assert(records[id].has("windows"))
        assert(HyprBridge.NAMES.has(id))
        assert(HyprBridge.TINTS.has(id))
    var current: int = HyprBridge.get_current()
    assert(current in ids)
    print("HYPR_BRIDGE_TEST_PASS: data schema, six whitelisted workspaces, current=", current)
    # Deliberately do not execute switch_to() in automated tests.
    quit(0)
