extends RefCounted
class_name JSceneMergeManager

func merge(local_jscene_diff:JSceneNodeDiff, remote_jscene_diff:JSceneNodeDiff) -> JSceneNodeMerge:
    var merged_node:JSceneNodeMerge = JSceneNodeMerge.new()

    # Start by copying diff 1 into resulting merge. It is used as "a base" for merging
    _copy_diff_into(local_jscene_diff, merged_node, null)
    # Then, merge the other diff into the merged scene
    _merge_diff_into(remote_jscene_diff, merged_node)

    return merged_node

func _copy_diff_into(local_jscene_diff:JSceneNodeDiff, merged_node:JSceneNodeMerge, parent_merged_node:JSceneNodeMerge) -> void:
    # Go for node
    merged_node.local_jscene_node_diff = local_jscene_diff
    merged_node.parent_node = parent_merged_node
    merged_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING if local_jscene_diff.has_delta() else JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    if merged_node.is_merged():
        merged_node.merged_jscene_node.node_name = local_jscene_diff.jscene_node.node_name
        merged_node.merged_jscene_node.node_type = local_jscene_diff.jscene_node.node_type

    # Go for groups
    for group_diff in local_jscene_diff.groups:
        var merged_group_node:JSceneNodeGroupMerge = JSceneNodeGroupMerge.new()
        merged_group_node.owner = merged_node
        merged_group_node.local_jscene_node_group_diff = group_diff
        merged_group_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING if group_diff.has_delta() else JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        if merged_group_node.is_merged():
            merged_group_node.merged_jscene_group.group_name = group_diff.jscene_group.group_name
        merged_node.groups.append(merged_group_node)

    # Go for properties
    for prop_diff in local_jscene_diff.properties:
        var merged_property_node:JSceneNodePropertyMerge = JSceneNodePropertyMerge.new()
        merged_property_node.owner = merged_node
        merged_property_node.local_jscene_node_property_diff = prop_diff
        merged_property_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING if prop_diff.has_delta() else JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        if merged_property_node.is_merged():
            merged_property_node.merged_jscene_property.property_name = prop_diff.jscene_property.property_name
            merged_property_node.merged_jscene_property.property_value = prop_diff.jscene_property.property_value
        merged_node.properties.append(merged_property_node)

    # Go for connections
    for conn_diff in local_jscene_diff.connections:
        var merged_connection_node:JSceneNodeConnectionMerge = JSceneNodeConnectionMerge.new()
        merged_connection_node.owner = merged_node
        merged_connection_node.local_jscene_node_connection_diff = conn_diff
        merged_connection_node.merged_jscene_connection.signal_name = conn_diff.jscene_connection.signal_name
        merged_connection_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING if not conn_diff.delta_connection.is_unchanged() else JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merged_connection_node.merge_status_flags = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING if not conn_diff.delta_connection_flags.is_unchanged() else JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        if merged_connection_node.merge_status_flags == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
            merged_connection_node.merged_jscene_connection.connection_flags = conn_diff.jscene_connection.connection_flags
        merged_connection_node.merge_status_target_path = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING if not conn_diff.delta_connection_target_path.is_unchanged() else JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        if merged_connection_node.merge_status_target_path == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
            merged_connection_node.merged_jscene_connection.connection_target_path = conn_diff.jscene_connection.connection_target_path
        merged_connection_node.merge_status_target_method = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING if not conn_diff.delta_connection_target_method.is_unchanged() else JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        if merged_connection_node.merge_status_target_method == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
            merged_connection_node.merged_jscene_connection.connection_target_method_name = conn_diff.jscene_connection.connection_target_method_name
        merged_connection_node.merge_status_binds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING if not conn_diff.delta_connection_binds.is_unchanged() else JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        if merged_connection_node.merge_status_binds == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
            merged_connection_node.merged_jscene_connection.connection_binds = conn_diff.jscene_connection.connection_binds
        merged_connection_node.merge_status_unbinds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING if not conn_diff.delta_connection_binds.is_unchanged() else JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        if merged_connection_node.merge_status_unbinds == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
            merged_connection_node.merged_jscene_connection.connection_unbinds = conn_diff.jscene_connection.connection_unbinds
        merged_node.connections.append(merged_connection_node)

    # Go for children
    for child_diff in local_jscene_diff.children:
        var merged_child_node:JSceneNodeMerge = JSceneNodeMerge.new()
        _copy_diff_into(child_diff, merged_child_node, merged_node)
        merged_node.children.append(merged_child_node)

func _merge_diff_into(remote_jscene_diff:JSceneNodeDiff, merged_root:JSceneNodeMerge) -> void:
    # Go for node
    var corresponding_merged_node:JSceneNodeMerge = merged_root.get_alternative_node_absolute(remote_jscene_diff.jscene_node.node_path, JsonSceneDiffManager.DIFF_REF_LOCAL)
    if corresponding_merged_node == null:
        # There is a possibility that node parent has been renamed
        # If so, child will not be found
        # Try to find the child withing it's renamed parent
        var potential_node_path:NodePath = NodePath(remote_jscene_diff.parent_node.alternative_node_path.get_concatenated_names() + "/" + remote_jscene_diff.jscene_node.node_name);
        corresponding_merged_node = merged_root.get_alternative_node_absolute(potential_node_path, JsonSceneDiffManager.DIFF_REF_LOCAL)

    if corresponding_merged_node != null:
        # Ok, found, node first
        corresponding_merged_node.remote_jscene_node_diff = remote_jscene_diff
        if corresponding_merged_node.is_merged() and remote_jscene_diff.has_delta():
            corresponding_merged_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING

        # Then groups
        for group_diff in remote_jscene_diff.groups:
            if group_diff.delta_group.is_added() or group_diff.delta_group.is_deleted():
                # Does not exists in merged node, add it
                var merged_group_node:JSceneNodeGroupMerge = JSceneNodeGroupMerge.new()
                merged_group_node.owner = corresponding_merged_node
                merged_group_node.remote_jscene_node_group_diff = group_diff
                merged_group_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING
                corresponding_merged_node.groups.append(merged_group_node)
            else:
                # Exists somewhere in merge node, find it and fullfil it
                for merged_group_node in corresponding_merged_node.groups:
                    if merged_group_node.local_jscene_node_group_diff.jscene_group.group_name == group_diff.jscene_group.group_name:
                        merged_group_node.remote_jscene_node_group_diff = group_diff
                        if merged_group_node.is_merged() and group_diff.has_delta():
                            merged_group_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING
                        break

        # Then properties
        for prop_diff in remote_jscene_diff.properties:
            if prop_diff.delta_property.is_added() or prop_diff.delta_property.is_deleted():
                # Does not exists in merged node, add it
                var merged_prop_node:JSceneNodePropertyMerge = JSceneNodePropertyMerge.new()
                merged_prop_node.owner = corresponding_merged_node
                merged_prop_node.remote_jscene_node_property_diff = prop_diff
                merged_prop_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING
                corresponding_merged_node.properties.append(merged_prop_node)
            else:
                # Exists somewhere in merge node, find it and fullfil it
                for merged_prop_node in corresponding_merged_node.properties:
                    if merged_prop_node.local_jscene_node_property_diff.jscene_property.property_name == prop_diff.jscene_property.property_name:
                        merged_prop_node.remote_jscene_node_property_diff = prop_diff
                        if merged_prop_node.is_merged() and prop_diff.has_delta():
                            merged_prop_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING
                        break

        # Then connections
        for conn_diff in remote_jscene_diff.connections:
            if conn_diff.delta_connection.is_added() or conn_diff.delta_connection.is_deleted():
                # Does not exists in merged node, add it
                var merged_conn_node:JSceneNodeConnectionMerge = JSceneNodeConnectionMerge.new()
                merged_conn_node.owner = corresponding_merged_node
                merged_conn_node.remote_jscene_node_connection_diff = conn_diff
                merged_conn_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING
                merged_conn_node.merge_status_flags = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
                merged_conn_node.merge_status_target_path = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
                merged_conn_node.merge_status_target_method = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
                merged_conn_node.merge_status_binds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
                merged_conn_node.merge_status_unbinds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
                corresponding_merged_node.connections.append(merged_conn_node)
            # Exists somewhere in merge node, find it and fullfil it
            for merged_conn_node in corresponding_merged_node.connections:
                if merged_conn_node.local_jscene_node_connection_diff.jscene_connection.signal_name == conn_diff.jscene_connection.signal_name:
                    merged_conn_node.remote_jscene_node_connection_diff = conn_diff
                    # There is not delta here on connection itself (signal name) since it can only be added or removed
                    # But there can be delta in connection properties
                    merged_conn_node.merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
                    if merged_conn_node.merge_status_flags == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED and not conn_diff.delta_connection_flags.is_unchanged():
                        merged_conn_node.merge_status_flags = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING
                    if merged_conn_node.merge_status_target_path == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED and not conn_diff.delta_connection_target_path.is_unchanged():
                        merged_conn_node.merge_status_target_path = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING
                    if merged_conn_node.merge_status_target_method == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED and not conn_diff.delta_connection_target_method.is_unchanged():
                        merged_conn_node.merge_status_target_method = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING
                    if merged_conn_node.merge_status_binds == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED and not conn_diff.delta_connection_binds.is_unchanged():
                        merged_conn_node.merge_status_binds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING
                    if merged_conn_node.merge_status_unbinds == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED and not conn_diff.delta_connection_unbinds.is_unchanged():
                        merged_conn_node.merge_status_unbinds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING
                    break
    else:
        # Not found : this is an addition to the existing scene
        # Check if we can found the parent, in order to add the node to right position
        # Else, add it to the root node...
        var corresponding_merged_parent_node:JSceneNodeMerge = merged_root.get_alternative_node_absolute(remote_jscene_diff.get_parent_node_path(), JsonSceneDiffManager.DIFF_REF_LOCAL)
        var merged_node:JSceneNodeMerge = JSceneNodeMerge.new()
        _copy_diff_into(remote_jscene_diff, merged_node, corresponding_merged_parent_node)
        # Insert node at "previously known" locations
        corresponding_merged_parent_node.children.insert(remote_jscene_diff.jscene_node.get_position_in_parent(), merged_node)


    # Go through children
    for child_diff in remote_jscene_diff.children:
        _merge_diff_into(child_diff, merged_root)
