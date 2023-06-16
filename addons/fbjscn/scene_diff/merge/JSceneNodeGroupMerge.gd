extends RefCounted
class_name JSceneNodeGroupMerge

var merge_status:int
var local_jscene_node_group_diff:JSceneNodeGroupDiff
var remote_jscene_node_group_diff:JSceneNodeGroupDiff
var merged_jscene_group:JSceneNodeGroup = JSceneNodeGroup.new()

var owner:JSceneNodeMerge

func is_merged() -> bool:
    return merge_status == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func is_added(merge_context:int) -> bool:
    return not is_merged() and \
            ((local_jscene_node_group_diff != null and local_jscene_node_group_diff.delta_group.is_added()) \
            or (remote_jscene_node_group_diff != null and remote_jscene_node_group_diff.delta_group.is_added()))

func is_modified(merge_context:int) -> bool:
    return not is_merged() and \
            ((local_jscene_node_group_diff != null and local_jscene_node_group_diff.delta_group.is_modified()) \
            or (remote_jscene_node_group_diff != null and remote_jscene_node_group_diff.delta_group.is_modified()))

func is_deleted(merge_context:int) -> bool:
    return not is_merged() and \
            ((local_jscene_node_group_diff != null and local_jscene_node_group_diff.delta_group.is_deleted()) \
            or (remote_jscene_node_group_diff != null and remote_jscene_node_group_diff.delta_group.is_deleted()))

func get_displayed_group_name() -> String:
    if is_merged():
        return merged_jscene_group.group_name
    else:
        if local_jscene_node_group_diff != null and remote_jscene_node_group_diff != null:
            return "%s ↔ %s" % [local_jscene_node_group_diff.jscene_group.group_name, remote_jscene_node_group_diff.jscene_group.group_name]
        elif local_jscene_node_group_diff != null:
            return local_jscene_node_group_diff.jscene_group.group_name
        else:
            return remote_jscene_node_group_diff.jscene_group.group_name

func update_value(merge_context:int, value:String) -> void:
    merged_jscene_group.group_name = value
    merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func accept_changes(merge_context:int) -> void:
    if is_added(merge_context):
        if local_jscene_node_group_diff != null:
            merged_jscene_group.group_name = local_jscene_node_group_diff.jscene_group.group_name
        elif remote_jscene_node_group_diff != null:
            merged_jscene_group.group_name = remote_jscene_node_group_diff.jscene_group.group_name
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    elif is_deleted(merge_context):
        merged_jscene_group = null
        owner.groups.erase(self)
        if local_jscene_node_group_diff != null:
            local_jscene_node_group_diff.owner.groups.erase(local_jscene_node_group_diff)
        if remote_jscene_node_group_diff != null:
            remote_jscene_node_group_diff.owner.groups.erase(remote_jscene_node_group_diff)
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    else:
        push_error("Can not accept changes if modified or already merged")

func discard_changes(merge_context:int) -> void:
    if is_added(merge_context):
        merged_jscene_group = null
        owner.groups.erase(self)
        if local_jscene_node_group_diff != null:
            local_jscene_node_group_diff.owner.groups.erase(local_jscene_node_group_diff)
        if remote_jscene_node_group_diff != null:
            remote_jscene_node_group_diff.owner.groups.erase(remote_jscene_node_group_diff)
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    elif is_deleted(merge_context):
        if local_jscene_node_group_diff != null:
            merged_jscene_group.group_name = local_jscene_node_group_diff.jscene_group.group_name
        elif remote_jscene_node_group_diff != null:
            merged_jscene_group.group_name = remote_jscene_node_group_diff.jscene_group.group_name
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    else:
        push_error("Can not discard changes if modified or already merged")

func accept_local_changes(merge_context:int) -> void:
    push_error("Can not accept local changes for groups")

func accept_remote_changes(merge_context:int) -> void:
    push_error("Can not accept remote changes for groups")

#------------------------------------------
# Fonctions privées
#------------------------------------------

