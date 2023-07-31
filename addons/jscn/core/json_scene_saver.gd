@tool
extends ResourceFormatSaver
class_name JsonSceneSaver

func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return ["jscn"]


func _recognize(resource: Resource) -> bool:
	return resource is PackedScene


func _save(resource: Resource, path: String, flags: int) -> Error:
	if not _recognize(resource):
		return ERR_UNAVAILABLE

	_save_jscn(resource, path, flags)
	return OK


func _find_resources(value:Variant) -> Array[Variant]:
	var resources:Array[Variant] = []

	match typeof(value):
		TYPE_ARRAY:
			for val in value:
				resources.append_array(_find_resources(val))
		TYPE_DICTIONARY:
			for key in value.keys():
				resources.append_array(_find_resources(key))
				resources.append_array(_find_resources(value[key]))
		TYPE_OBJECT:
			if value:
				var object:Object = value as Object
				for prop in object.get_property_list():
					if prop["usage"] & PROPERTY_USAGE_STORAGE:
						var prop_value:Variant = object.get(prop["name"])
						if prop["usage"] & PROPERTY_USAGE_RESOURCE_NOT_PERSISTENT == PROPERTY_USAGE_RESOURCE_NOT_PERSISTENT:
							pass
						else:
							resources.append_array(_find_resources(prop_value))
				resources.append(object)

	return resources

func _save_jscn(resource: Resource, path: String, flags: int) -> void:
	var jsonScene:Dictionary = { }
	if resource is PackedScene:
		jsonScene["version"] = 1
		_scene_state_to_json(resource.get_state(), jsonScene)

	var file:FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(jsonScene, "  ", false))
	print(file)

func _scene_state_to_json(state:SceneState, json:Dictionary) -> void:
	var all_nodes:Array[Dictionary] = []
	for n in state.get_node_count():
		all_nodes.push_back(_node_to_json(state, n))

	var connection_count:int = state.get_connection_count()
	if connection_count > 0:
		for conn_index in connection_count:
			var connection_flags:int = state.get_connection_flags(conn_index)
			var connection_binds:Array = state.get_connection_binds(conn_index)
			var connection_method:String = state.get_connection_method(conn_index)
			var connection_signal:String = state.get_connection_signal(conn_index)
			var connection_source:NodePath = state.get_connection_source(conn_index)
			var connection_target:NodePath = state.get_connection_target(conn_index)
			var connection_unbind_count:int = state.get_connection_unbinds(conn_index)

			for node in all_nodes:
				if node["path"] == connection_source:
					if not node.has("connections"):
						node["connections"] = []

					var json_connection:Dictionary = {
						"signal" : connection_signal,
						"flags" : connection_flags,
						"target_path" : connection_target,
						"target_method" : connection_method
					}
					if not connection_binds.is_empty():
						json_connection["binds"] = []
						for bind_arg in connection_binds:
							json_connection["binds"].push_back(var_to_str(bind_arg))
					if connection_unbind_count > 0:
						json_connection["unbind"] = connection_unbind_count
					node["connections"].push_back(json_connection)
					break

	json["tree"] = { }
	for json_node in all_nodes:
		if json_node["path"] == ^".":
			json["tree"][json_node["name"]] = json_node
		else:
			var parent:Dictionary = json["tree"][json["tree"].keys()[0]]
			for n in json_node["path"].get_name_count() - 1:
				var parent_name:String = json_node["path"].get_name(n)
				if (parent_name == "."):
					parent = parent
				else:
					parent = parent["children"][parent_name]
			if not parent.has("children"):
				parent["children"] = { }
			parent["children"][json_node["name"]] = json_node

		json_node.erase("name")
		json_node.erase("path")

func _node_to_json(state:SceneState, node_index:int) -> Dictionary:
	var json:Dictionary = { }

	var node_name:String = state.get_node_name(node_index)
	var node_type:String = state.get_node_type(node_index)
	var node_path:NodePath = state.get_node_path(node_index)
	var node_groups:PackedStringArray = state.get_node_groups(node_index)

	json["name"] = node_name
	json["type"] = node_type
	json["path"] = node_path
	if not node_groups.is_empty():
		json["groups"] = node_groups

	var property_count:int = state.get_node_property_count(node_index)
	if property_count > 0:
		json["properties"] = { }
		for prop_index in range(property_count):
			var property_name:String = state.get_node_property_name(node_index, prop_index)
			var property_value:Variant = state.get_node_property_value(node_index, prop_index)
			if property_value is Resource:
				json["properties"][property_name] = {
					"resource_name" : property_value.resource_name,
					"resource_path" : property_value.resource_path,
					"resource_local_to_scene" : property_value.resource_local_to_scene
				}
				if property_value.resource_local_to_scene and property_value is GDScript:
					json["properties"][property_name]["source_code"] = property_value.source_code
			else :
				json["properties"][property_name] = var_to_str(property_value)

	return json
