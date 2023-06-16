extends RefCounted
class_name JsonSceneDiffManager

enum {
	DIFF_REF_LOCAL,
	DIFF_REF_REMOTE
}

func diff(jscene_node1:JSceneNode, jscene_node2:JSceneNode, diff_ref:int) -> JSceneNodeDiff:
	var diff:JSceneNodeDiff = JSceneNodeDiff.new()

	# Root node is particular, since it can not be added/removed : only modified !
	_diff_root_node_only(jscene_node1, jscene_node2, diff)
	# After that, treat it like any other nodes : groups, properties, signals !
	_diff_node_content(jscene_node1, jscene_node2, diff, diff_ref)

	# Then proceed to root children, as normal nodes
	for child in jscene_node1.children:
		_diff_node(child, jscene_node2, diff, diff_ref)

	return diff

func _diff_root_node_only(jscene_root1:JSceneNode, jscene_root2:JSceneNode, diff:JSceneNodeDiff) -> void:
	diff.jscene_node = jscene_root1
	diff.alternative_node_path = ^"."

	var delta_node:JSceneDelta = JSceneDelta.new(JSceneNodeDiff.JSCENE_NODE_DELTA_NODE)
	var delta_node_name:JSceneDelta = JSceneDelta.new(JSceneNodeDiff.JSCENE_NODE_DELTA_NODE_NAME)
	var delta_node_type:JSceneDelta = JSceneDelta.new(JSceneNodeDiff.JSCENE_NODE_DELTA_NODE_TYPE)
	var delta_node_position_in_parent:JSceneDelta = JSceneDelta.new(JSceneNodeDiff.JSCENE_NODE_DELTA_NODE_POSITION_IN_PARENT)

	if jscene_root1.node_name != jscene_root2.node_name:
		delta_node_name.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED
		delta_node_name.original = jscene_root1
		delta_node_name.other = jscene_root2

	if jscene_root1.node_type != jscene_root2.node_type:
		delta_node_type.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED
		delta_node_type.original = jscene_root1
		delta_node_type.other = jscene_root2

	delta_node_position_in_parent.delta_type = JSceneDelta.JSCENE_DELTA_UNCHANGED
	delta_node_position_in_parent.original = jscene_root1
	delta_node_position_in_parent.other = jscene_root2

	if delta_node_name.is_modified() or delta_node_type.is_modified():
		delta_node.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED
	delta_node.original = jscene_root1
	delta_node.other = jscene_root2

	diff.delta_node = delta_node
	diff.delta_node_name = delta_node_name
	diff.delta_node_type = delta_node_type
	diff.delta_node_position_in_parent = delta_node_position_in_parent

func _diff_node(jscene_node1:JSceneNode, jscene_root2:JSceneNode, jscene_parent_diff:JSceneNodeDiff, diff_ref:int) -> void:
	var diff:JSceneNodeDiff = JSceneNodeDiff.new()
	diff.jscene_node = jscene_node1
	diff.parent_node = jscene_parent_diff

	# Try to find the node in the other scene
	# There is a corner case where a node can be renamed ; since we look for other node by comparing
	# node paths, it will not be found. In that case, look into possible other parent node a child with
	# "a certain compatibility"
	var jscene_other_node:JSceneNode = null
	if jscene_root2 != null:
		jscene_other_node = jscene_root2.get_node_absolute(NodePath(diff.get_parent_node_path().get_concatenated_names() + "/" + jscene_node1.node_name))
		if jscene_other_node == null:
			# There is always a parent diff when here !
			jscene_other_node = _try_find_compatible_node(jscene_node1, jscene_root2, jscene_parent_diff)

	# Depending on node has been found or not,
	# - if not found, depending on diff_ref, it's an addition/deletion of the node tree
	if jscene_other_node == null:
		var delta_node:JSceneDelta = JSceneDelta.new(JSceneNodeDiff.JSCENE_NODE_DELTA_NODE)
		delta_node.original = jscene_node1
		if diff_ref == DIFF_REF_LOCAL:
			delta_node.delta_type = JSceneDelta.JSCENE_DELTA_DELETED
		else:
			delta_node.delta_type = JSceneDelta.JSCENE_DELTA_ADDED
		diff.delta_node = delta_node
		diff.alternative_node_path = NodePath(diff.get_parent_alternative_node_path().get_concatenated_names() + "/" + jscene_node1.node_name)
		jscene_parent_diff.children.append(diff)
		# Then node content ; , it will be added/deleted too
		_diff_node_content(jscene_node1, null, diff, diff_ref)

		# Then proceed to root children, as normal nodes, they will all be added/deleted too
		for child in jscene_node1.children:
			_diff_node(child, null, diff, diff_ref)
	else:
		#Node found, do plain diff
		var delta_node:JSceneDelta = JSceneDelta.new(JSceneNodeDiff.JSCENE_NODE_DELTA_NODE)
		delta_node.original = jscene_node1
		delta_node.other = jscene_other_node
		var delta_node_name:JSceneDelta = JSceneDelta.new(JSceneNodeDiff.JSCENE_NODE_DELTA_NODE_NAME)
		delta_node_name.original = jscene_node1
		delta_node_name.other = jscene_other_node
		var delta_node_type:JSceneDelta = JSceneDelta.new(JSceneNodeDiff.JSCENE_NODE_DELTA_NODE_TYPE)
		delta_node_type.original = jscene_node1
		delta_node_type.other = jscene_other_node
		var delta_node_position_in_parent:JSceneDelta = JSceneDelta.new(JSceneNodeDiff.JSCENE_NODE_DELTA_NODE_POSITION_IN_PARENT)
		delta_node_position_in_parent.original = jscene_node1
		delta_node_position_in_parent.other = jscene_other_node

		if jscene_node1.node_name != jscene_other_node.node_name:
			delta_node_name.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED
			diff.alternative_node_path = NodePath(diff.get_parent_alternative_node_path().get_concatenated_names() + "/" + jscene_other_node.node_name)
		else:
			diff.alternative_node_path = NodePath(diff.get_parent_alternative_node_path().get_concatenated_names() + "/" + jscene_node1.node_name)
		if jscene_node1.node_type != jscene_other_node.node_type:
			delta_node_type.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED
		if jscene_node1.get_position_in_parent() != jscene_other_node.get_position_in_parent():
			delta_node_position_in_parent.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED

		if delta_node_name.is_modified() or delta_node_type.is_modified() or delta_node_position_in_parent.is_modified():
			delta_node.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED

		diff.delta_node = delta_node
		diff.delta_node_name = delta_node_name
		diff.delta_node_type = delta_node_type
		diff.delta_node_position_in_parent = delta_node_position_in_parent
		jscene_parent_diff.children.append(diff)
		_diff_node_content(jscene_node1, jscene_other_node, diff, diff_ref)

		# Then proceed to root children, as normal nodes
		for child in jscene_node1.children:
			_diff_node(child, jscene_root2, diff, diff_ref)

func _diff_node_content(jscene_node1:JSceneNode, jscene_node2:JSceneNode, diff:JSceneNodeDiff, diff_ref:int) -> void:
	_diff_node_groups(jscene_node1, jscene_node2, diff, diff_ref)
	_diff_node_properties(jscene_node1, jscene_node2, diff, diff_ref)
	_diff_node_connections(jscene_node1, jscene_node2, diff, diff_ref)

func _diff_node_groups(jscene_node1:JSceneNode, jscene_node2:JSceneNode, diff:JSceneNodeDiff, diff_ref:int) -> void:
	for group in jscene_node1.groups:
		# Compute delta
		var jscene_node2_group:JSceneNodeGroup = null
		if jscene_node2 != null:
			jscene_node2_group = jscene_node2.get_group(group.group_name)

		var delta_group:JSceneDelta = JSceneDelta.new(JSceneNodeGroupDiff.JSCENE_NODE_DELTA_GROUP)
		delta_group.original = group
		delta_group.other = jscene_node2_group
		if jscene_node2_group == null:
			if diff_ref == DIFF_REF_LOCAL:
				delta_group.delta_type = JSceneDelta.JSCENE_DELTA_DELETED
			else:
				delta_group.delta_type = JSceneDelta.JSCENE_DELTA_ADDED
		else:
			delta_group.delta_type = JSceneDelta.JSCENE_DELTA_UNCHANGED

		# Register diff in diff node
		var jscene_node_group_diff:JSceneNodeGroupDiff = JSceneNodeGroupDiff.new()
		jscene_node_group_diff.owner = diff
		jscene_node_group_diff.jscene_group = group
		jscene_node_group_diff.delta_group = delta_group
		diff.groups.append(jscene_node_group_diff)

func _diff_node_properties(jscene_node1:JSceneNode, jscene_node2:JSceneNode, diff:JSceneNodeDiff, diff_ref:int) -> void:
	for prop in jscene_node1.properties:
		# Compute delta
		var jscene_node2_prop:JSceneNodeProperty = null
		if jscene_node2 != null:
			jscene_node2_prop = jscene_node2.get_property(prop.property_name)

		var delta_prop:JSceneDelta = JSceneDelta.new(JSceneNodePropertyDiff.JSCENE_NODE_DELTA_PROPERTY)
		delta_prop.original = prop
		delta_prop.other = jscene_node2_prop
		if jscene_node2_prop == null:
			if diff_ref == DIFF_REF_LOCAL:
				delta_prop.delta_type = JSceneDelta.JSCENE_DELTA_DELETED
			else:
				delta_prop.delta_type = JSceneDelta.JSCENE_DELTA_ADDED
		else:
			# Found, but can be modified !
			if prop.property_value != jscene_node2_prop.property_value:
				delta_prop.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED
			else:
				delta_prop.delta_type = JSceneDelta.JSCENE_DELTA_UNCHANGED

		# Register diff in diff node
		var jscene_node_prop_diff:JSceneNodePropertyDiff = JSceneNodePropertyDiff.new()
		jscene_node_prop_diff.owner = diff
		jscene_node_prop_diff.jscene_property = prop
		jscene_node_prop_diff.delta_property = delta_prop
		diff.properties.append(jscene_node_prop_diff)

func _diff_node_connections(jscene_node1:JSceneNode, jscene_node2:JSceneNode, diff:JSceneNodeDiff, diff_ref:int) -> void:
	for conn in jscene_node1.connections:
		# Compute delta
		var jscene_node2_conn:JSceneNodeConnection = null
		if jscene_node2 != null:
			jscene_node2_conn = jscene_node2.get_connection(conn.signal_name)

		var delta_conn:JSceneDelta = JSceneDelta.new(JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION)
		delta_conn.original = conn
		delta_conn.other = jscene_node2_conn
		var delta_conn_flags:JSceneDelta = JSceneDelta.new(JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_FLAGS)
		delta_conn_flags.original = conn
		delta_conn_flags.other = jscene_node2_conn
		var delta_conn_target_path:JSceneDelta = JSceneDelta.new(JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH)
		delta_conn_target_path.original = conn
		delta_conn_target_path.other = jscene_node2_conn
		var delta_conn_target_method:JSceneDelta = JSceneDelta.new(JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD)
		delta_conn_target_method.original = conn
		delta_conn_target_method.other = jscene_node2_conn
		var delta_conn_binds:JSceneDelta = JSceneDelta.new(JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_BINDS)
		delta_conn_binds.original = conn
		delta_conn_binds.other = jscene_node2_conn
		var delta_conn_unbinds:JSceneDelta = JSceneDelta.new(JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_UNBINDS)
		delta_conn_unbinds.original = conn
		delta_conn_unbinds.other = jscene_node2_conn

		if jscene_node2_conn == null:
			if diff_ref == DIFF_REF_LOCAL:
				delta_conn.delta_type = JSceneDelta.JSCENE_DELTA_DELETED
			else:
				delta_conn.delta_type = JSceneDelta.JSCENE_DELTA_ADDED
		else:
			# Modification or unchanged ?
			if conn.connection_flags != jscene_node2_conn.connection_flags:
				delta_conn_flags.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED
			if conn.connection_target_path != jscene_node2_conn.connection_target_path:
				delta_conn_target_path.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED
			if conn.connection_target_method_name != jscene_node2_conn.connection_target_method_name:
				delta_conn_target_method.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED
			if conn.connection_binds != jscene_node2_conn.connection_binds:
				delta_conn_binds.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED
			if conn.connection_unbinds != jscene_node2_conn.connection_unbinds:
				delta_conn_unbinds.delta_type = JSceneDelta.JSCENE_DELTA_MODIFIED

		# Register diffs in diff node
		var jscene_node_conn_diff:JSceneNodeConnectionDiff = JSceneNodeConnectionDiff.new()
		jscene_node_conn_diff.owner = diff
		jscene_node_conn_diff.jscene_connection = conn
		jscene_node_conn_diff.delta_connection = delta_conn
		jscene_node_conn_diff.delta_connection_flags = delta_conn_flags
		jscene_node_conn_diff.delta_connection_target_path = delta_conn_target_path
		jscene_node_conn_diff.delta_connection_target_method = delta_conn_target_method
		jscene_node_conn_diff.delta_connection_binds = delta_conn_binds
		jscene_node_conn_diff.delta_connection_unbinds = delta_conn_unbinds
		diff.connections.append(jscene_node_conn_diff)


func _try_find_compatible_node(jscene_node1:JSceneNode, jscene_root2:JSceneNode, jscene_parent_diff:JSceneNodeDiff) -> JSceneNode:
	# Try to find the parent node in the other scene
	if jscene_parent_diff != null:
		var other_parent_node:JSceneNode = null
		if jscene_root2 != null:
			other_parent_node = jscene_root2.get_node_absolute(jscene_parent_diff.alternative_node_path)

		if other_parent_node != null:
			# Parent node found ! Maybe it's just a renaming ?
			# Check in other parent children if there is a node with same type, same number of children, ...
			for other_child in other_parent_node.children:
				if other_child.node_type == jscene_node1.node_type:
					# Candidate node !
					var similarity:float = _compute_similarity(jscene_node1, other_child)
					if similarity > 0.65:
						return other_child

	return null

func _compute_similarity(jscene_node1:JSceneNode, jscene_node2:JSceneNode) -> float:
	var number_of_node_content:int = 2
	var number_of_groups:int = jscene_node1.groups.size()
	var number_of_properties:int = jscene_node1.properties.size()
	var number_of_connections:int = jscene_node1.connections.size()
	var number_of_children:int = jscene_node1.children.size()

	var total_possible_similarity:int = number_of_node_content + number_of_groups + number_of_properties + number_of_connections + number_of_children
	if total_possible_similarity == 0:
		return 0

	var similarity_count:int = 0

	if jscene_node1.node_name == jscene_node2.node_name:
		similarity_count += 1
	if jscene_node1.node_type == jscene_node2.node_type:
		similarity_count += 1
	for group in jscene_node1.groups:
		similarity_count += 1 if jscene_node2.get_group(group.group_name) != null else 0
	for prop in jscene_node1.properties:
		similarity_count += 1 if jscene_node2.get_property(prop.property_name) != null else 0
	for conn in jscene_node1.connections:
		similarity_count += 1 if jscene_node2.get_connection(conn.signal_name) != null else 0
	for child in jscene_node1.children:
		similarity_count += 1 if jscene_node2.get_child(child.node_name) != null else 0

	return similarity_count * 1.0 / total_possible_similarity

