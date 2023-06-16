@tool
extends ResourceFormatLoader
class_name JsonSceneLoader

func _init() -> void:
	print("INITIALIZED")

func _rename_dependencies(path: String, renames: Dictionary) -> Error:
	print("_rename_dependencies %s %s" % [path, renames])
	return OK

func _get_recognized_extensions() -> PackedStringArray:
	return ["jscn", "tres", "escn"]

func _get_classes_used(path: String) -> PackedStringArray:
	print("_get_classes_used %s" % path)
	return []

func _get_dependencies(path: String, add_types: bool) -> PackedStringArray:
	print("_get_dependencies %s %s" % [path, add_types])
	if path.ends_with(".jscn"):
		var json_scene:Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		var tree_root:Dictionary = json_scene["tree"][json_scene["tree"].keys()[0]]
		if tree_root.has("properties") and tree_root["properties"].has("script"):
			return [tree_root["properties"]["script"].resource_path]
	return []

func _get_resource_script_class(path: String) -> String:
	print("_get_resource_script_class %s" % [path])
	if path.ends_with(".jscn"):
		var json_scene:Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		var tree_root:Dictionary = json_scene["tree"][json_scene["tree"].keys()[0]]
		if tree_root.has("properties") and tree_root["properties"].has("script"):
			return tree_root["properties"]["script"].resource_path
	return ""

func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	print("_load %s %s" % [path, original_path])
	if GitHelper.file_has_conflicts(path):
		var popup:ConflictingWindow = preload("res://addons/fbjscn/scenes/conflict_window.tscn").instantiate()
		popup.conflicting_scene = GitHelper.get_onflicting_scene(path)
		Engine.get_main_loop().root.add_child(popup)
		popup.popup_centered()
		return null

	var json_scene:Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))

	print("CUSTOM ! LOAD")
	var packedScene:PackedScene = PackedScene.new()
	var root:Node = _create_node(json_scene["tree"].keys()[0], json_scene["tree"][json_scene["tree"].keys()[0]])
	_connect_signals(root, root)
	root.print_tree_pretty()
	packedScene.pack(root)
	packedScene.set_meta("jscn_loaded", true)
	return packedScene

func _connect_signals(root:Node, node:Node) -> void:
	var json_node:Dictionary = node.get_meta("jscnraw")
	node.remove_meta("jscnraw")
	if json_node.has("connections"):
		for connection in json_node["connections"]:
			var target_node_path:NodePath = NodePath(connection["target_path"])
			var target_method_name:StringName = StringName(connection["target_method"])
			var target_node:Node = root.get_node_or_null(target_node_path)
			if not is_instance_valid(target_node):
				push_error("Can not connect signal %s to %s : node not found !" % [connection["signal"], target_node_path])
			else:
				print("     * connecting signal %s to node %s.%s" % [connection["signal"], target_node_path, target_method_name])
				var callable:Callable = Callable(target_node, target_method_name)
				if connection.has("binds"):
					print("          * binds = %s (type is %s)" % [connection["binds"], typeof(connection["binds"])])
					var bind_args:Array = []
					for str_bind_arg in connection["binds"]:
						bind_args.push_back(str_to_var(str_bind_arg))
					print("                   * bind_args = %s" % [bind_args])
					callable = callable.bindv(bind_args)
				print("           * callable = %s" % [callable.get_bound_arguments()])
				if connection.get("unbind", 0) > 0:
					callable = callable.unbind(connection["unbind"])
				node.connect(connection["signal"], callable, connection["flags"])

	for child in node.get_children():
		_connect_signals(root, child)

func _create_node(node_name:String, json_node:Dictionary, owner_node:Node = null, parent_node:Node = null) -> Node:
	print(" > Handling node %s or type %s" % [node_name, json_node["type"]])
	var node:Node = ClassDB.instantiate(json_node["type"])
	node.name = node_name
	if parent_node != null :
		print("    > %s is child of %s" % [node.get_name(), parent_node.get_name()])
		parent_node.add_child(node)
	if owner_node != null:
		node.owner = owner_node
	else:
		owner_node = node

	node.set_meta("jscnraw", json_node)

	if json_node.has("groups"):
		for group in json_node["groups"]:
			node.add_to_group(StringName(group), true)

	if json_node.has("properties"):
		for prop_name in json_node["properties"].keys():
			var value:Variant = json_node["properties"][prop_name]
			if value is Dictionary :
				if value.has("source_code"):
					var script:GDScript = GDScript.new()
					script.source_code = value["source_code"]
					script.reload()
					node.set(prop_name, script)
				else:
					node.set(prop_name, load(value["resource_path"]))
			else:
				node.set(prop_name, str_to_var(value))

	if json_node.has("children"):
		for json_child in json_node["children"].keys():
			_create_node(json_child, json_node["children"][json_child], owner_node, node)

	return node

func _handles_type(type: StringName) -> bool:
	print("_handles_type %s" % type)
	return type == "PackedScene"

func _get_resource_type(path: String) -> String:
	var can_handle:bool = false
	if path.ends_with(".tres") or path.ends_with(".jscn") or path.ends_with(".escn"):
		can_handle = true
	print("can_handle %s: %s" % [path, can_handle])
	return "PackedScene" if can_handle else ""

func _exists(path: String) -> bool:
	print("_exists %s : %s" % [path, FileAccess.file_exists(path)])
	return FileAccess.file_exists(path)
