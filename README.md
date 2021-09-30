# godot-plugin-interop
A snippet of code for enabling interoperability between plugins.

## Installation
- Copy these files into your plugin (wherever you like)

## Usage
In your plugin, preload the class and register and deregister your plugin:

```swift
var Interop = preload("path/to/interop.gd")

func _enter_tree() -> void:
    Interop.register(self, "ply")
    ...

func _exit_tree() -> void:
    Interop.deregister(self, "ply")
    ...
```

Make use of it elsewhere:
```swift
if event.pressed and is_selecting():
    var gsr = Interop.get_plugin_or_null(my_plugin, "gsr")
    if gsr and gsr.state != gsr.GSRState.NONE:
        return
```

The first argument must be your plugin for each interop function call.

### Emitting and Consuming Work State

Plugins can tell every other plugin that they started a workload, so other plugins can make decisions about what to do:
```swift
func start()
    Interop.start_work(self, "plugin_work")
    ...

func commit()
    Interop.end_work(self, "plugin_work")
    ...
```

Plugins can consume this via the optional `_interop_notification` virtual function:
```swift
func _interop_notification(caller_plugin: EditorPlugin, what, args):
    match what:
        Interop.NOTIFY_CODE_WORK_STARTED:
            match args:
                "plugin_transform":
                    toolbar.toggle_plugin_buttons(false)
        Interop.NOTIFY_CODE_WORK_ENDED:
            match args:
                "plugin_transform":
                    toolbar.toggle_plugin_buttons(true)
```

Builtin Notification Codes:
```swift
NOTIFY_CODE_WORK_STARTED = 1 -> string
NOTIFY_CODE_WORK_ENDED = 2 -> string
```
