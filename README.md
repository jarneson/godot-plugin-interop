# godot-plugin-interop
A snippet of code for enabling interoperability between plugins. Allows plugins to get the object of another plugin which registered itself or to broadcast notifications with arguments.

## Installation
- Copy the files in this repository into your plugin. It's best practice to have a folder just for the files of the interop, but it's not required.

## Usage
In your plugin, preload the class and register / deregister your plugin.
Note that the first argument must be your plugin for each interop function call.

```swift
var Interop = preload("path/to/interop.gd")

# Enable and disable as your plugin is added or removed from the tree:

func _enter_tree() -> void:
    # Change the string to anything that identifies your plugin
    Interop.register(self, "custom_plugin_identifier")
    ...

func _exit_tree() -> void:
    Interop.deregister(self) 
    ...
```

Make use of it elsewhere:
```swift
    # For example in the input handling method:
    if event.pressed and is_selecting():
        # Change string here too. my_plugin can be self if called from main script.
        var other_plugin = Interop.get_plugin_or_null(my_plugin, "name_of_other_plugin")
        if other_plugin and other_plugin.state != 15:
            return
```

To receive notifications from other plugins, declare this in your plugin:
```swift
func _interop_notification(caller_plugin: String, code: int, id: String, args):
    ... # Do something based on the arguments
```
The arguments depend on the notification code. See below.

### Emitting and consuming work state

Plugins can tell every other plugin that they started or ended work. Other plugins can make decisions based on this:
```swift
func start()
    # Notifies other plugins that you started something. The custom_arguments value is optional.
    Interop.start_work(self, "name_of_work", custom_arguments)
    ...

func commit()
    # Always have this paired with start_work() with the same string. The custom_arguments value is optional.
    Interop.end_work(self, "name_of_work", custom_arguments)
    ...
```

You can request other plugins to not access input for a while:
```swift
    # Plugins that respect this call will not do anything when a key is pressed or the mouse is moved
    # or its button is clicked.
    Interop.grab_full_input(self)
    
    ...
    
    # Make sure to call this somewhere later:
    Interop.release_full_input(self)
```

### Handling the notifications:

Plugins can consume notifications via the optional `_interop_notification` virtual function. The `code`
argument is the code of the notification (see below). The `id` and `args` depend on the `code` and the
plugin sending the notification. See their respective documentation.
```swift
func _interop_notification(caller_plugin_id: String, code: int, id: String, args):
    match code:
        Interop.NOTIFY_CODE_WORK_STARTED:
            match id:
                "plugin_transform": # Custom id from the caller plugin.
                    toolbar.toggle_plugin_buttons(false)
        Interop.NOTIFY_CODE_WORK_ENDED:
            match id:
                "plugin_transform": # Custom id from the caller plugin.
                    toolbar.toggle_plugin_buttons(true)
```

## Builtin notification codes:
Notification when a plugin starts doing work which will be in progress until NOTIFY_CODE_WORK_ENDED notification is received.\
The `id` argument should be identifying the work started.
*See documentation of the interoperating plugins for the values of id and args (optional).*\
**const NOTIFY_CODE_WORK_STARTED = 1**

Notification when a plugin finished a work that was in progress after you received NOTIFY_CODE_WORK_STARTED.\
The `id` argument should be identifying the work that's ending.
*See documentation of the interoperating plugins for the values of id and args (optional).*\
**const NOTIFY_CODE_WORK_ENDED = 2**

Notification when a plugin requests every other plugin to not react to input. Should be followed by NOTIFY_CODE_ALLOW_INPUT.\
*No `id` or `args` apply. They will be empty or null.*\
**const NOTIFY_CODE_REQUEST_IGNORE_INPUT = 3**

Notification when a plugin stops requesting every other plugin to not react to input.\
*No `id` or `args` apply. They will be empty or null.*\
**const NOTIFY_CODE_ALLOW_INPUT = 4**

### Custom plugin notifications:
You can define any value as notification code in your plugin. To be tidy and not clash with the notification codes of the
interop script, define your codes as a combination of NOTIFY_CODE_USER and a value like this:
```swift
const MY_NOTIFY_CODE = Interop.NOTIFY_CODE_USER + 0
const MY_SECOND_NOTIFY_CODE = Interop.NOTIFY_CODE_USER + 1
```

To broadcast a notification, write:
```swift
    # This is just an example. Use your codes, id strings, and arguments.
    # Both the id and arguments are optional.
    Interop.notify_plugins(self, MY_NOTIFY_CODE, "my_custom_id_string", [1, 2, some_value])
```

You can then include a list of your code constants in your documentation for other plugins to use. Don't forget to mention the value
of `id` and `args` if you use them.
