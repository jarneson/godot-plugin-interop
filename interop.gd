"""
MIT License

Copyright (c) 2021 Jeffrey Arneson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

tool
extends Node

const NOTIFY_CODE_WORK_STARTED = 1
const NOTIFY_CODE_WORK_ENDED = 2

const _PLUGIN_NODE_NAME = "plugin_interop"
const _PLUGIN_DICTIONARY = "PluginDictionary"

static func register(plugin: EditorPlugin, plugin_name: String):
	var base_control = plugin.get_editor_interface().get_base_control()
	var n: Node = base_control.get_node_or_null(_PLUGIN_NODE_NAME)
	if n == null:
		n = Node.new()
		n.name = _PLUGIN_NODE_NAME
		base_control.add_child(n)
	var plugins = n.get_meta(_PLUGIN_DICTIONARY) if n.has_meta(_PLUGIN_DICTIONARY) else null
	if plugins == null:
		plugins = {}
	assert(!plugins.has(plugin_name), 'Plugin "%s" already registered for interop' % [plugin_name])
	plugins[plugin_name] = plugin
	n.set_meta(_PLUGIN_DICTIONARY, plugins)

static func ___get_interop_node(plugin: EditorPlugin):
	var n: Node = plugin.get_editor_interface().get_base_control().get_node_or_null(_PLUGIN_NODE_NAME)
	assert(n != null, "Interop node does not exist. Make sure to register your plugin first.")
	return n

static func deregister(plugin: EditorPlugin, plugin_name: String):
	var n: Node = ___get_interop_node(plugin)
	var plugins = n.get_meta(_PLUGIN_DICTIONARY) if n.has_meta(_PLUGIN_DICTIONARY) else null
	assert(plugins != null && plugins.has(plugin_name), 'Plugin "%s" not registered, cannot deregister' % [plugin_name])
	assert(plugins != null && plugins[plugin_name] == plugin, 'Plugin "%s" registered with different object, cannot deregister, was: %s expected: %s' % [plugin_name, plugins[plugin_name], plugin])
	plugins.erase(plugin_name)
	if plugins.empty():
		n.queue_free()
	else:
		n.set_meta(_PLUGIN_DICTIONARY, plugins)
	

static func get_plugin_or_null(plugin: EditorPlugin, name_to_find: String):
	var n: Node = ___get_interop_node(plugin)
	var plugins = n.get_meta(_PLUGIN_DICTIONARY) if n.has_meta(_PLUGIN_DICTIONARY) else null
	if plugins == null:
		return null
	return plugins.get(name_to_find)

static func _notify_plugins(plugin: EditorPlugin, code: int, args):
	var n: Node = ___get_interop_node(plugin)
	var plugins = n.get_meta(_PLUGIN_DICTIONARY) if n.has_meta(_PLUGIN_DICTIONARY) else null
	if plugins == null:
		return null
	for name in plugins:
		var p = plugins[name]
		if p.has_method("_interop_notification"):
			p._interop_notification(plugin, code, args)

static func start_work(plugin: EditorPlugin, what):
	_notify_plugins(plugin, NOTIFY_CODE_WORK_STARTED, what)

static func end_work(plugin: EditorPlugin, what):
	_notify_plugins(plugin, NOTIFY_CODE_WORK_ENDED, what)
