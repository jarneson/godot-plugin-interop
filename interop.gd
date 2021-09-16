static func get_instance(p):
    var base_control = p.get_editor_interface().get_base_control()
    var existing = base_control.get_node_or_null("plugin_interop")
    if existing:
        print("Interop already installed")
        return existing
    var n = load("res://addons/<PLUGIN_NAME>/interop_node.gd").new()
    n.name = "plugin_interop"
    base_control.add_child(n)
    return n
