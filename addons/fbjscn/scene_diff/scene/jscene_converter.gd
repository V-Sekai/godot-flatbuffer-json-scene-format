extends RefCounted
class_name JSceneConverter

static func to_jscene_node(json_scene:Dictionary) -> JSceneNode:
	if not json_scene.has("version"):
		push_error("No version in json scene. Unable to deserialize")
		return null

	if json_scene["version"] != 1:
		push_error("Unknown version in json scene, expected 1, got %s" % json_scene["version"])
		return null

	if not json_scene.has("tree"):
		push_error("Invalide json scene format")
		return null

	if json_scene["tree"].is_empty():
		push_error("Expected a root node in json scene")
		return null

	var json_node_name:String = json_scene["tree"].keys()[0]
	var json_root_node:Dictionary = json_scene["tree"][json_node_name]
	return _recursive_to_json_node(^".", json_node_name, json_root_node, null)

static func _recursive_to_json_node(json_node_path:NodePath, json_node_name:String, json_node:Dictionary, jscene_node_parent) -> JSceneNode:
	if not json_node.has("type"):
		push_error("Expected note type for node %s (%s)" % [json_node_path, json_node_name])
		return null

	var jscene_node:JSceneNode = JSceneNode.new()

	# Node
	jscene_node.node_name = json_node_name
	jscene_node.node_path = json_node_path
	jscene_node.node_type = json_node["type"]
	jscene_node.parent_node = jscene_node_parent

	# Groups
	if json_node.has("groups"):
		for group in json_node["groups"]:
			var jscene_group:JSceneNodeGroup = JSceneNodeGroup.new()
			jscene_group.owner = jscene_node
			jscene_group.group_name = group
			jscene_node.groups.append(jscene_group)

	# Properties
	if json_node.has("properties"):
		for prop_name in json_node["properties"]:
			var jscene_property:JSceneNodeProperty = JSceneNodeProperty.new()
			jscene_property.owner = jscene_node
			jscene_property.property_name = prop_name
			jscene_property.property_value = str_to_var(json_node["properties"][prop_name])
			jscene_node.properties.append(jscene_property)

	# Signals
	if json_node.has("connections"):
		for connection in json_node["connections"]:
			var jscene_connection:JSceneNodeConnection = JSceneNodeConnection.new()
			jscene_connection.owner = jscene_node
			jscene_connection.signal_name = connection["signal"]
			jscene_connection.connection_flags = connection["flags"]
			jscene_connection.connection_target_path = NodePath(connection["target_path"])
			jscene_connection.connection_target_method_name = connection["target_method"]
			if connection.has("binds"):
				for bind in connection["binds"]:
					jscene_connection.connection_binds.append(str_to_var(bind))
			if connection.has("unbind"):
				jscene_connection.connection_unbinds = connection["unbind"]
			jscene_node.connections.append(jscene_connection)

	# Children
	if json_node.has("children"):
		for child_name in json_node["children"]:
			var jscene_child:JSceneNode = _recursive_to_json_node(NodePath(json_node_path.get_concatenated_names() + "/" + child_name), child_name, json_node["children"][child_name], jscene_node)
			jscene_node.children.append(jscene_child)

	jscene_node.normalize()
	return jscene_node
