extends RefCounted
class_name JSceneNode

var node_name:String
var node_path:NodePath
var node_type:String

var groups:Array[JSceneNodeGroup]
var properties:Array[JSceneNodeProperty]
var connections:Array[JSceneNodeConnection]

var parent_node:JSceneNode
var children:Array[JSceneNode]

func normalize() -> void:
	groups.sort_custom(func(g1, g2): return g1.group_name <= g2.group_name)
	properties.sort_custom(func(p1, p2): return p1.property_name <= p2.property_name)
	connections.sort_custom(func(c1, c2): return c1.signal_name <= c2.signal_name)

func get_parent_node_path() -> NodePath:
	if parent_node == null:
		return ^""
	else:
		return parent_node.node_path

func get_position_in_parent() -> int:
	return 0 if parent_node == null else parent_node.children.find(self)

func get_node_absolute(expected_node_path:NodePath) -> JSceneNode:
	var root:JSceneNode = self
	while root.parent_node != null:
		root = root.parent_node

	return root._recursive_node_search(expected_node_path)

func get_previous_sibling() -> JSceneNode:
	var pos_in_parent:int = get_position_in_parent()
	if pos_in_parent > 0:
		return parent_node.children[pos_in_parent - 1]
	return null

func get_group(group_name:String) -> JSceneNodeGroup:
	for group in groups:
		if group.group_name == group_name:
			return group
	return null

func get_property(property_name:String) -> JSceneNodeProperty:
	for prop in properties:
		if prop.property_name == property_name:
			return prop
	return null

func get_connection(signal_name:String) -> JSceneNodeConnection:
	for conn in connections:
		if conn.signal_name == signal_name:
			return conn
	return null

func get_child(node_name:String) -> JSceneNode:
	for child in children:
		if child.node_name == node_name:
			return child
	return null

func serialize() -> Dictionary:
	var serialized_node:Dictionary = {
		node_name : { }
	}

	# Node itself
	serialized_node[node_name]["type"] = node_type

	# Groups
	if not groups.is_empty():
		serialized_node[node_name]["groups"] = groups.map(func(g): return g.group_name)

	# Properties
	if not properties.is_empty():
		var serialized_properties:Dictionary = { }
		for prop in properties:
			serialized_properties[prop.property_name] = var_to_str(prop.property_value)
		serialized_node[node_name]["properties"] = serialized_properties

	# Connections
	if not connections.is_empty():
		serialized_node[node_name]["connections"] = connections.map(func(conn): return {
			"signal" : conn.signal_name,
			"flags" : conn.connection_flags,
			"target_path" : conn.connection_target_path,
			"target_method" : conn.connection_target_method_name,
			"binds" : conn.connection_binds.map(func(b): return var_to_str(b)),
			"unbinds" : conn.connection_unbinds
		})

	# Children
	if not children.is_empty():
		var serialized_children:Dictionary = { }
		for child in children:
			serialized_children.merge(child.serialize(), true)
		serialized_node[node_name]["children"] = serialized_children

	return serialized_node

func _recursive_node_search(expected_node_path:NodePath) -> JSceneNode:
	if expected_node_path == node_path:
		return self

	for child in children:
		var found_node:JSceneNode = child._recursive_node_search(expected_node_path)
		if found_node != null:
			return found_node

	return null
