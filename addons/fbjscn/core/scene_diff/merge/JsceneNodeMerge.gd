extends RefCounted
class_name JSceneNodeMerge

var merge_status:int
var local_jscene_node_diff:JSceneNodeDiff
var remote_jscene_node_diff:JSceneNodeDiff
var merged_jscene_node:JSceneNode = JSceneNode.new()

var groups:Array[JSceneNodeGroupMerge]
var properties:Array[JSceneNodePropertyMerge]
var connections:Array[JSceneNodeConnectionMerge]

var parent_node:JSceneNodeMerge
var children:Array[JSceneNodeMerge]

func get_consolidated_merged_node(node_path:NodePath = ^".") -> JSceneNode:
    var consolidated_node:JSceneNode = JSceneNode.new()

    # Node itself
    consolidated_node.node_name = merged_jscene_node.node_name
    consolidated_node.node_type = merged_jscene_node.node_type
    consolidated_node.node_path = node_path

    # Groups
    for group in groups:
        var consolidated_group:JSceneNodeGroup = JSceneNodeGroup.new()
        consolidated_group.owner = consolidated_node
        consolidated_group.group_name = group.merged_jscene_group.group_name
        consolidated_node.groups.append(consolidated_group)

    # Properties
    for prop in properties:
        var consolidated_prop:JSceneNodeProperty = JSceneNodeProperty.new()
        consolidated_prop.owner = consolidated_node
        consolidated_prop.property_name = prop.merged_jscene_property.property_name
        consolidated_prop.property_value = prop.merged_jscene_property.property_value
        consolidated_node.properties.append(consolidated_prop)

    # Connections
    for conn in connections:
        var consolidated_conn:JSceneNodeConnection = JSceneNodeConnection.new()
        consolidated_conn.owner = consolidated_node
        consolidated_conn.signal_name = conn.merged_jscene_connection.signal_name
        consolidated_conn.connection_flags = conn.merged_jscene_connection.connection_flags
        consolidated_conn.connection_target_path = conn.merged_jscene_connection.connection_target_path
        consolidated_conn.connection_target_method_name = conn.merged_jscene_connection.connection_target_method_name
        consolidated_conn.connection_binds = conn.merged_jscene_connection.connection_binds
        consolidated_conn.connection_unbinds = conn.merged_jscene_connection.connection_unbinds
        consolidated_node.connections.append(consolidated_conn)

    # Children
    for child in children:
        var consolidated_chil:JSceneNode = child.get_consolidated_merged_node(NodePath(node_path.get_concatenated_names() + "/" + child.merged_jscene_node.node_name))
        consolidated_chil.parent_node = consolidated_node
        consolidated_node.children.append(consolidated_chil)

    consolidated_node.normalize()
    return consolidated_node

func get_unmerged_changes_count() -> int:
    var count:int = 0

    # Node
    if not is_merged():
        count += 1
    # Groups
    for group in groups:
        if not group.is_merged():
            count += 1
    # Properties
    for prop in properties:
        if not prop.is_merged():
            count += 1
    # Connections
    for conn in connections:
        if conn.merge_status == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING:
            count += 1
        else:
            if conn.merge_status_flags == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING:
                count += 1
            if conn.merge_status_target_path == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING:
                count += 1
            if conn.merge_status_target_method == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING:
                count += 1
            if conn.merge_status_binds == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING:
                count += 1
            if conn.merge_status_unbinds == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_PENDING:
                count += 1

    for child in children:
        count += child.get_unmerged_changes_count()

    return count

func is_merged() -> bool:
    return merge_status == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func get_alternative_node_absolute(expected_node_path:NodePath, diff_ref:int) -> JSceneNodeMerge:
    var root:JSceneNodeMerge = self
    while root.parent_node != null:
        root = root.parent_node

    return root._recursive_node_search(expected_node_path, diff_ref)

func is_added(merge_context:int) -> bool:
    return not is_merged() and \
            ((local_jscene_node_diff != null and local_jscene_node_diff.delta_node.is_added()) \
            or (remote_jscene_node_diff != null and remote_jscene_node_diff.delta_node.is_added()))

func is_modified(merge_context:int) -> bool:
    return not is_merged() and \
            ((local_jscene_node_diff != null and \
                    (local_jscene_node_diff.delta_node.is_modified() \
                            or (local_jscene_node_diff.delta_node_name != null and local_jscene_node_diff.delta_node_name.is_modified()) \
                            or (local_jscene_node_diff.delta_node_position_in_parent != null and local_jscene_node_diff.delta_node_position_in_parent.is_modified()) \
                            or (local_jscene_node_diff.delta_node_type != null and local_jscene_node_diff.delta_node_type.is_modified()))) \
            or (remote_jscene_node_diff != null and \
                    (remote_jscene_node_diff.delta_node.is_modified() \
                            or (remote_jscene_node_diff.delta_node_name != null and remote_jscene_node_diff.delta_node_name.is_modified()) \
                            or (remote_jscene_node_diff.delta_node_position_in_parent != null and remote_jscene_node_diff.delta_node_position_in_parent.is_modified()) \
                            or (remote_jscene_node_diff.delta_node_type != null and remote_jscene_node_diff.delta_node_type.is_modified()))))

func is_only_position_modification(merge_context:int) -> bool:
    return not is_merged() and not is_added(merge_context) and not is_deleted(merge_context) \
            and not local_jscene_node_diff.delta_node_name.is_modified() \
            and not local_jscene_node_diff.delta_node_type.is_modified() \
            and local_jscene_node_diff.delta_node_position_in_parent.is_modified() \
            and not remote_jscene_node_diff.delta_node_name.is_modified() \
            and not remote_jscene_node_diff.delta_node_type.is_modified() \
            and remote_jscene_node_diff.delta_node_position_in_parent.is_modified()

func is_deleted(merge_context:int) -> bool:
    return not is_merged() and \
            ((local_jscene_node_diff != null and local_jscene_node_diff.delta_node.is_deleted()) \
            or (remote_jscene_node_diff != null and remote_jscene_node_diff.delta_node.is_deleted()))

func get_displayed_node_name() -> String:
    if is_merged():
        return merged_jscene_node.node_name
    else:
        if local_jscene_node_diff != null and remote_jscene_node_diff != null:
            if local_jscene_node_diff.jscene_node.node_name == remote_jscene_node_diff.jscene_node.node_name:
                return local_jscene_node_diff.jscene_node.node_name
            else:
                return "%s ↔ %s" % [local_jscene_node_diff.jscene_node.node_name, remote_jscene_node_diff.jscene_node.node_name]
        elif local_jscene_node_diff != null:
            return local_jscene_node_diff.jscene_node.node_name
        else:
            return remote_jscene_node_diff.jscene_node.node_name

func get_displayed_node_type() -> String:
    if is_merged():
        return merged_jscene_node.node_type
    else:
        if local_jscene_node_diff != null and remote_jscene_node_diff != null:
            if local_jscene_node_diff.jscene_node.node_type == remote_jscene_node_diff.jscene_node.node_type:
                return local_jscene_node_diff.jscene_node.node_type
            else:
                return "%s ↔ %s" % [local_jscene_node_diff.jscene_node.node_type, remote_jscene_node_diff.jscene_node.node_type]
        elif local_jscene_node_diff != null:
            return local_jscene_node_diff.jscene_node.node_type
        else:
            return remote_jscene_node_diff.jscene_node.node_type

func get_displayed_node_position_changed() -> String:
    if is_merged():
        return ""
    else:
        if local_jscene_node_diff != null and local_jscene_node_diff.delta_node_position_in_parent != null:
            if local_jscene_node_diff.delta_node_position_in_parent.is_modified():
                return " (Position changed)"
        elif remote_jscene_node_diff != null and remote_jscene_node_diff.delta_node_position_in_parent:
            if remote_jscene_node_diff.delta_node_position_in_parent.is_modified():
                return " (Position changed)"
    return ""

func mark_as_merged(merge_context:int) -> void:
    merged_jscene_node.node_name = local_jscene_node_diff.jscene_node.node_name
    merged_jscene_node.node_type = local_jscene_node_diff.jscene_node.node_type
    merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func accept_changes(merge_context:int) -> void:
    if is_added(merge_context):
        if local_jscene_node_diff != null:
            merged_jscene_node.node_name = local_jscene_node_diff.jscene_node.node_name
            merged_jscene_node.node_type = local_jscene_node_diff.jscene_node.node_type
        elif remote_jscene_node_diff != null:
            merged_jscene_node.node_name = remote_jscene_node_diff.jscene_node.node_name
            merged_jscene_node.node_type = remote_jscene_node_diff.jscene_node.node_type
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    elif is_deleted(merge_context):
        merged_jscene_node = null
        if parent_node != null:
            parent_node.children.erase(self)
        if local_jscene_node_diff != null:
            local_jscene_node_diff.parent_node.children.erase(local_jscene_node_diff)
        if remote_jscene_node_diff != null:
            remote_jscene_node_diff.parent_node.children.erase(remote_jscene_node_diff)
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    else:
        push_error("Can not accept changes if modified or already merged")

func discard_changes(merge_context:int) -> void:
    if is_added(merge_context):
        merged_jscene_node = null
        if parent_node != null:
            parent_node.children.erase(self)
        if local_jscene_node_diff != null:
            local_jscene_node_diff.parent_node.children.erase(local_jscene_node_diff)
        if remote_jscene_node_diff != null:
            remote_jscene_node_diff.parent_node.children.erase(remote_jscene_node_diff)
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    elif is_deleted(merge_context):
        if local_jscene_node_diff != null:
            merged_jscene_node.node_name = local_jscene_node_diff.jscene_node.node_name
            merged_jscene_node.node_type = local_jscene_node_diff.jscene_node.node_type
        elif remote_jscene_node_diff != null:
            merged_jscene_node.node_name = remote_jscene_node_diff.jscene_node.node_name
            merged_jscene_node.node_type = remote_jscene_node_diff.jscene_node.node_type
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    else:
        push_error("Can not discard changes if modified or already merged")

func accept_local_changes(merge_context:int) -> void:
    if not is_modified(merge_context):
        push_error("Can not accept local changes if not modified or already merge")
        return

    merged_jscene_node.node_name = local_jscene_node_diff.jscene_node.node_name
    merged_jscene_node.node_type = local_jscene_node_diff.jscene_node.node_type
    merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func accept_remote_changes(merge_context:int) -> void:
    if not is_modified(merge_context):
        push_error("Can not accept remote changes if not modified or already merge")
        return

    merged_jscene_node.node_name = remote_jscene_node_diff.jscene_node.node_name
    merged_jscene_node.node_type = remote_jscene_node_diff.jscene_node.node_type
    merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _recursive_node_search(expected_node_path:NodePath, diff_ref:int) -> JSceneNodeMerge:
    var checked_node_path
    if diff_ref == JsonSceneDiffManager.DIFF_REF_LOCAL:
        if local_jscene_node_diff != null:
            checked_node_path = local_jscene_node_diff.alternative_node_path
    else:
        if remote_jscene_node_diff != null:
            checked_node_path = remote_jscene_node_diff.alternative_node_path

    if expected_node_path == checked_node_path:
        return self

    for child in children:
        var found_node:JSceneNodeMerge = child._recursive_node_search(expected_node_path, diff_ref)
        if found_node != null:
            return found_node

    return null
