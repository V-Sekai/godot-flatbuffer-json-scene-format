extends RefCounted
class_name JSceneNodeConnectionMerge

var merge_status:int
var merge_status_flags:int
var merge_status_target_path:int
var merge_status_target_method:int
var merge_status_binds:int
var merge_status_unbinds:int

var local_jscene_node_connection_diff:JSceneNodeConnectionDiff
var remote_jscene_node_connection_diff:JSceneNodeConnectionDiff
var merged_jscene_connection:JSceneNodeConnection = JSceneNodeConnection.new()

var owner:JSceneNodeMerge

func is_merged() -> bool:
    return merge_status == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED \
            and merge_status_flags == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED \
            and merge_status_target_path == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED \
            and merge_status_target_method == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED \
            and merge_status_binds == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED \
            and merge_status_unbinds == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func is_added(merge_context:int) -> bool:
    return not is_merged() and merge_context == JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION and \
            ((local_jscene_node_connection_diff != null and local_jscene_node_connection_diff.delta_connection.is_added()) \
            or (remote_jscene_node_connection_diff != null and remote_jscene_node_connection_diff.delta_connection.is_added()))

func is_modified(merge_context:int) -> bool:
    if is_merged():
        return false

    # When modified, both are provided
    # And both are modified, so we can take one of them to take the information
    if local_jscene_node_connection_diff != null and remote_jscene_node_connection_diff != null:
        match merge_context:
            JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION:
                return local_jscene_node_connection_diff.delta_connection.is_modified()
            JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_FLAGS:
                return local_jscene_node_connection_diff.delta_connection_flags.is_modified()
            JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH:
                return local_jscene_node_connection_diff.delta_connection_target_path.is_modified()
            JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD:
                return local_jscene_node_connection_diff.delta_connection_target_method.is_modified()
            JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_BINDS:
                return local_jscene_node_connection_diff.delta_connection_binds.is_modified()
            JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_UNBINDS:
                return local_jscene_node_connection_diff.delta_connection_unbinds.is_modified()

    return false

func is_deleted(merge_context:int) -> bool:
    return not is_merged() and merge_context == JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION and \
            ((local_jscene_node_connection_diff != null and local_jscene_node_connection_diff.delta_connection.is_deleted()) \
            or (remote_jscene_node_connection_diff != null and remote_jscene_node_connection_diff.delta_connection.is_deleted()))

func get_displayed_signal_name() -> String:
    if merge_status == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return merged_jscene_connection.signal_name
    else:
        if local_jscene_node_connection_diff:
            return local_jscene_node_connection_diff.jscene_connection.signal_name
        else:
            return remote_jscene_node_connection_diff.jscene_connection.signal_name

func get_displayed_flags() -> int:
    if merge_status_flags == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return merged_jscene_connection.connection_flags
    else:
        if local_jscene_node_connection_diff != null:
            return local_jscene_node_connection_diff.jscene_connection.connection_flags
        else:
            return remote_jscene_node_connection_diff.jscene_connection.connection_flags

func get_displayed_flags_value() -> String:
    if merge_status_flags == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return _connection_flags_to_str(merged_jscene_connection.connection_flags)
    else:
        if local_jscene_node_connection_diff != null and remote_jscene_node_connection_diff != null:
            return "%s ↔ %s" % [_connection_flags_to_str(local_jscene_node_connection_diff.jscene_connection.connection_flags), _connection_flags_to_str(remote_jscene_node_connection_diff.jscene_connection.connection_flags)]
        elif local_jscene_node_connection_diff != null:
            return _connection_flags_to_str(local_jscene_node_connection_diff.jscene_connection.connection_flags)
        else:
            return _connection_flags_to_str(remote_jscene_node_connection_diff.jscene_connection.connection_flags)

func _connection_flags_to_str(flags:int) -> String:
    var ret:String = ""
    if flags & CONNECT_DEFERRED == CONNECT_DEFERRED:
        ret += "CONNECT_DEFERRED"
    if flags & CONNECT_ONE_SHOT == CONNECT_ONE_SHOT:
        if not ret.is_empty():
            ret += ", "
        ret += "CONNECT_ONE_SHOT"
    if flags & CONNECT_PERSIST == CONNECT_PERSIST:
        if not ret.is_empty():
            ret += ", "
        ret += "CONNECT_PERSIST"
    if flags & CONNECT_REFERENCE_COUNTED == CONNECT_REFERENCE_COUNTED:
        if not ret.is_empty():
            ret += ", "
        ret += "CONNECT_REFERENCE_COUNTED"
    return ret

func get_displayed_target_path() -> NodePath:
    if merge_status_target_path == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return merged_jscene_connection.connection_target_path
    else:
        if local_jscene_node_connection_diff != null:
            return local_jscene_node_connection_diff.jscene_connection.connection_target_path
        else:
            return remote_jscene_node_connection_diff.jscene_connection.connection_target_path

func get_displayed_target_path_value() -> String:
    if merge_status_target_path == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return merged_jscene_connection.connection_target_path
    else:
        if local_jscene_node_connection_diff != null and remote_jscene_node_connection_diff != null:
            return "%s ↔ %s" % [local_jscene_node_connection_diff.jscene_connection.connection_target_path, remote_jscene_node_connection_diff.jscene_connection.connection_target_path]
        elif local_jscene_node_connection_diff != null:
            return local_jscene_node_connection_diff.jscene_connection.connection_target_path
        else:
            return remote_jscene_node_connection_diff.jscene_connection.connection_target_path

func get_displayed_target_method() -> String:
    if merge_status_target_path == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return merged_jscene_connection.connection_target_method_name
    else:
        if local_jscene_node_connection_diff != null:
            return local_jscene_node_connection_diff.jscene_connection.connection_target_method_name
        else:
            return remote_jscene_node_connection_diff.jscene_connection.connection_target_method_name

func get_displayed_target_method_value() -> String:
    if merge_status_target_method == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return merged_jscene_connection.connection_target_method_name
    else:
        if local_jscene_node_connection_diff != null and remote_jscene_node_connection_diff != null:
            return "%s ↔ %s" % [local_jscene_node_connection_diff.jscene_connection.connection_target_method_name, remote_jscene_node_connection_diff.jscene_connection.connection_target_method_name]
        elif local_jscene_node_connection_diff != null:
            return local_jscene_node_connection_diff.jscene_connection.connection_target_method_name
        else:
            return remote_jscene_node_connection_diff.jscene_connection.connection_target_method_name

func get_displayed_binds() -> Array[Variant]:
    if merge_status_target_path == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return merged_jscene_connection.connection_binds
    else:
        if local_jscene_node_connection_diff != null:
            return local_jscene_node_connection_diff.jscene_connection.connection_binds
        else:
            return remote_jscene_node_connection_diff.jscene_connection.connection_binds

func get_displayed_binds_value() -> String:
    if merge_status_binds == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return var_to_str(merged_jscene_connection.connection_binds)
    else:
        if local_jscene_node_connection_diff != null and remote_jscene_node_connection_diff != null:
            return "%s ↔ %s" % [var_to_str(local_jscene_node_connection_diff.jscene_connection.connection_binds), var_to_str(remote_jscene_node_connection_diff.jscene_connection.connection_binds)]
        elif local_jscene_node_connection_diff != null:
            return "%s" % var_to_str(local_jscene_node_connection_diff.jscene_connection.connection_binds)
        else:
            return "%s" % var_to_str(remote_jscene_node_connection_diff.jscene_connection.connection_binds)

func get_displayed_unbinds() -> int:
    if merge_status_target_path == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return merged_jscene_connection.connection_unbinds
    else:
        if local_jscene_node_connection_diff != null:
            return local_jscene_node_connection_diff.jscene_connection.connection_unbinds
        else:
            return remote_jscene_node_connection_diff.jscene_connection.connection_unbinds

func get_displayed_unbinds_value() -> String:
    if merge_status_unbinds == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED:
        return var_to_str(merged_jscene_connection.connection_unbinds)
    else:
        if local_jscene_node_connection_diff != null and remote_jscene_node_connection_diff != null:
            return "%s ↔ %s" % [var_to_str(local_jscene_node_connection_diff.jscene_connection.connection_unbinds), var_to_str(remote_jscene_node_connection_diff.jscene_connection.connection_unbinds)]
        elif local_jscene_node_connection_diff != null:
            return var_to_str(local_jscene_node_connection_diff.jscene_connection.connection_unbinds)
        else:
            return var_to_str(remote_jscene_node_connection_diff.jscene_connection.connection_unbinds)

func update_value(merge_context:int, value:Variant) -> void:
    match merge_context:
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_FLAGS:
            merged_jscene_connection.connection_flags = value
            merge_status_flags = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH:
            merged_jscene_connection.connection_target_path = value
            merge_status_target_path = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD:
            merged_jscene_connection.connection_target_method_name = value
            merge_status_target_method = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_BINDS:
            merged_jscene_connection.connection_binds = value
            merge_status_binds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_UNBINDS:
            merged_jscene_connection.connection_unbinds = value
            merge_status_unbinds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func accept_changes(merge_context:int) -> void:
    if is_added(merge_context):
        if local_jscene_node_connection_diff != null:
            merged_jscene_connection.signal_name = local_jscene_node_connection_diff.jscene_connection.signal_name
            merged_jscene_connection.connection_flags = local_jscene_node_connection_diff.jscene_connection.connection_flags
            merged_jscene_connection.connection_target_path = local_jscene_node_connection_diff.jscene_connection.connection_target_path
            merged_jscene_connection.connection_target_method_name = local_jscene_node_connection_diff.jscene_connection.connection_target_method_name
            merged_jscene_connection.connection_binds = local_jscene_node_connection_diff.jscene_connection.connection_binds
            merged_jscene_connection.connection_unbinds = local_jscene_node_connection_diff.jscene_connection.connection_unbinds
        elif remote_jscene_node_connection_diff != null:
            merged_jscene_connection.signal_name = remote_jscene_node_connection_diff.jscene_connection.signal_name
            merged_jscene_connection.connection_flags = remote_jscene_node_connection_diff.jscene_connection.connection_flags
            merged_jscene_connection.connection_target_path = remote_jscene_node_connection_diff.jscene_connection.connection_target_path
            merged_jscene_connection.connection_target_method_name = remote_jscene_node_connection_diff.jscene_connection.connection_target_method_name
            merged_jscene_connection.connection_binds = remote_jscene_node_connection_diff.jscene_connection.connection_binds
            merged_jscene_connection.connection_unbinds = remote_jscene_node_connection_diff.jscene_connection.connection_unbinds
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_flags = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_target_path = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_target_method = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_binds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_unbinds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    elif is_deleted(merge_context):
        merged_jscene_connection = null
        owner.connections.erase(self)
        if local_jscene_node_connection_diff != null:
            local_jscene_node_connection_diff.owner.connections.erase(local_jscene_node_connection_diff)
        if remote_jscene_node_connection_diff != null:
            remote_jscene_node_connection_diff.owner.connections.erase(remote_jscene_node_connection_diff)
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_flags = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_target_path = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_target_method = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_binds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_unbinds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    else:
        push_error("Can not accept changes if modified or already merged")

func discard_changes(merge_context:int) -> void:
    if is_added(merge_context):
        merged_jscene_connection = null
        owner.connections.erase(self)
        if local_jscene_node_connection_diff != null:
            local_jscene_node_connection_diff.owner.connections.erase(local_jscene_node_connection_diff)
        if remote_jscene_node_connection_diff != null:
            remote_jscene_node_connection_diff.owner.connections.erase(remote_jscene_node_connection_diff)
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_flags = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_target_path = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_target_method = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_binds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_unbinds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    elif is_deleted(merge_context):
        if local_jscene_node_connection_diff != null:
            merged_jscene_connection.signal_name = local_jscene_node_connection_diff.jscene_connection.signal_name
            merged_jscene_connection.connection_flags = local_jscene_node_connection_diff.jscene_connection.connection_flags
            merged_jscene_connection.connection_target_path = local_jscene_node_connection_diff.jscene_connection.connection_target_path
            merged_jscene_connection.connection_target_method_name = local_jscene_node_connection_diff.jscene_connection.connection_target_method_name
            merged_jscene_connection.connection_binds = local_jscene_node_connection_diff.jscene_connection.connection_binds
            merged_jscene_connection.connection_unbinds = local_jscene_node_connection_diff.jscene_connection.connection_unbinds
        elif remote_jscene_node_connection_diff != null:
            merged_jscene_connection.signal_name = remote_jscene_node_connection_diff.jscene_connection.signal_name
            merged_jscene_connection.connection_flags = remote_jscene_node_connection_diff.jscene_connection.connection_flags
            merged_jscene_connection.connection_target_path = remote_jscene_node_connection_diff.jscene_connection.connection_target_path
            merged_jscene_connection.connection_target_method_name = remote_jscene_node_connection_diff.jscene_connection.connection_target_method_name
            merged_jscene_connection.connection_binds = remote_jscene_node_connection_diff.jscene_connection.connection_binds
            merged_jscene_connection.connection_unbinds = remote_jscene_node_connection_diff.jscene_connection.connection_unbinds
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_flags = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_target_path = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_target_method = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_binds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        merge_status_unbinds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    else:
        push_error("Can not discard changes if modified or already merged")

func accept_local_changes(merge_context:int) -> void:
    if not is_modified(merge_context):
        push_error("Can not accept local changes if not modified or already merge")
        return

    match merge_context:
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_FLAGS:
            merged_jscene_connection.connection_flags = local_jscene_node_connection_diff.jscene_connection.connection_flags
            merge_status_flags = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH:
            merged_jscene_connection.connection_target_path = local_jscene_node_connection_diff.jscene_connection.connection_target_path
            merge_status_target_path = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD:
            merged_jscene_connection.connection_target_method_name = local_jscene_node_connection_diff.jscene_connection.connection_target_method_name
            merge_status_target_method = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_BINDS:
            merged_jscene_connection.connection_binds = local_jscene_node_connection_diff.jscene_connection.connection_binds
            merge_status_binds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_UNBINDS:
            merged_jscene_connection.connection_unbinds = local_jscene_node_connection_diff.jscene_connection.connection_unbinds
            merge_status_unbinds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func accept_remote_changes(merge_context:int) -> void:
    if not is_modified(merge_context):
        push_error("Can not accept local changes if not modified or already merge")
        return

    match merge_context:
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_FLAGS:
            merged_jscene_connection.connection_flags = remote_jscene_node_connection_diff.jscene_connection.connection_flags
            merge_status_flags = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH:
            merged_jscene_connection.connection_target_path = remote_jscene_node_connection_diff.jscene_connection.connection_target_path
            merge_status_target_path = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD:
            merged_jscene_connection.connection_target_method_name = remote_jscene_node_connection_diff.jscene_connection.connection_target_method_name
            merge_status_target_method = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_BINDS:
            merged_jscene_connection.connection_binds = remote_jscene_node_connection_diff.jscene_connection.connection_binds
            merge_status_binds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
        JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_UNBINDS:
            merged_jscene_connection.connection_unbinds = remote_jscene_node_connection_diff.jscene_connection.connection_unbinds
            merge_status_unbinds = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
