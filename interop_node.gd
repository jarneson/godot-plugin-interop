extends Node

var plugin_dictionary = {}

func register(name, plugin):
    assert(not plugin_dictionary.has(name), 'Plugin "%s" already registered for interop' % [name])
    plugin_dictionary[name] = plugin

func deregister(name, plugin):
    assert(plugin_dictionary.has(name), 'Plugin "%s" not registered, cannot deregister' % [name])
    assert(plugin_dictionary[name] == plugin, 'Plugin "%s" registered with different object, cannot deregister, was: %s expected: %s' % [name, plugin_dictionary[name], plugin])
    plugin_dictionary.erase(name)

func get_plugin_or_null(name):
    return plugin_dictionary.get(name)