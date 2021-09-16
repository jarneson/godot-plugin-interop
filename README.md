# godot-plugin-interop
A snippet of code for enabling interoperability between plugins.

## Installation
- Copy these files into your plugin (wherever you like)
- Update the `<PLUGIN_NAME>` placeholder in interop.gd

## Usage
In your plugin, register and deregister your plugin:

```
var interop = null
func _enter_tree() -> void:
    interop = Interop.get_instance(self)
    interop.register("ply", self)
    ...

func _exit_tree() -> void:
    interop.deregister("ply", self)
    ...
```

Make use of it elsewhere:
```
if event.pressed and is_selecting():
    var gsr = _plugin.interop.get_plugin_or_null("gsr")
    if gsr and gsr.state != gsr.GSRState.NONE:
        return
```

### Emitting and Consuming Work State

Plugins can tell every other plugin that they started a workload, so other plugins can make decisions about what to do:
```
func start()
	interop.start_work("plugin_work")
    ...

func commit()
    interop.end_work("plugin_work")
    ...
```

Plugins can consume this via the optional `_interop_notification(what, args)` function:
```
    match what:
        interop.NOTIFY_CODE_WORK_STARTED:
            match args:
                "plugin_transform":
                    toolbar.toggle_plugin_buttons(false)
        interop.NOTIFY_CODE_WORK_ENDED:
            match args:
                "plugin_transform":
                    toolbar.toggle_plugin_buttons(true)
```

Builtin Notification Codes:
```
NOTIFY_CODE_WORK_STARTED = 1 -> string
NOTIFY_CODE_WORK_ENDED = 2 -> string
```