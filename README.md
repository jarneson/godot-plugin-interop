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