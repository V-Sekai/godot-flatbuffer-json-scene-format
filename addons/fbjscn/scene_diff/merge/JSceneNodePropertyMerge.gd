extends RefCounted
class_name JSceneNodePropertyMerge

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var merge_status:int
var local_jscene_node_property_diff:JSceneNodePropertyDiff
var remote_jscene_node_property_diff:JSceneNodePropertyDiff
var merged_jscene_property:JSceneNodeProperty = JSceneNodeProperty.new()

var owner:JSceneNodeMerge

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func is_merged() -> bool:
    return merge_status == JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func is_added(merge_context:int) -> bool:
    return not is_merged() and \
            ((local_jscene_node_property_diff != null and local_jscene_node_property_diff.delta_property.is_added()) \
            or (remote_jscene_node_property_diff != null and remote_jscene_node_property_diff.delta_property.is_added()))

func is_modified(merge_context:int) -> bool:
    return not is_merged() and \
            ((local_jscene_node_property_diff != null and local_jscene_node_property_diff.delta_property.is_modified()) \
            or (remote_jscene_node_property_diff != null and remote_jscene_node_property_diff.delta_property.is_modified()))

func is_deleted(merge_context:int) -> bool:
    return not is_merged() and \
            ((local_jscene_node_property_diff != null and local_jscene_node_property_diff.delta_property.is_deleted()) \
            or (remote_jscene_node_property_diff != null and remote_jscene_node_property_diff.delta_property.is_deleted()))

func get_displayed_property_name() -> String:
    if is_merged():
        return merged_jscene_property.property_name
    else:
        if local_jscene_node_property_diff != null:
            return local_jscene_node_property_diff.jscene_property.property_name
        else:
            return remote_jscene_node_property_diff.jscene_property.property_name

func get_displayed_property_value() -> String:
    if is_merged():
        return var_to_str(merged_jscene_property.property_value)
    else:
        if local_jscene_node_property_diff != null and remote_jscene_node_property_diff != null:
            return "%s ↔ %s" % [var_to_str(local_jscene_node_property_diff.jscene_property.property_value), var_to_str(remote_jscene_node_property_diff.jscene_property.property_value)]
        elif local_jscene_node_property_diff != null:
            return var_to_str(local_jscene_node_property_diff.jscene_property.property_value)
        else:
            return var_to_str(remote_jscene_node_property_diff.jscene_property.property_value)

func get_displayed_property() -> Variant:
    if is_merged():
        return merged_jscene_property.property_value
    else:
        if local_jscene_node_property_diff != null:
            return local_jscene_node_property_diff.jscene_property.property_value
        else:
            return remote_jscene_node_property_diff.jscene_property.property_value

func update_value(merge_context:int, value:Variant) -> void:
    if local_jscene_node_property_diff != null:
        merged_jscene_property.property_name = local_jscene_node_property_diff.jscene_property.property_name
    elif remote_jscene_node_property_diff != null:
        merged_jscene_property.property_name = remote_jscene_node_property_diff.jscene_property.property_name
    merged_jscene_property.property_value = value
    merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func accept_changes(merge_context:int) -> void:
    if is_added(merge_context):
        if local_jscene_node_property_diff != null:
            merged_jscene_property.property_name = local_jscene_node_property_diff.jscene_property.property_name
            merged_jscene_property.property_value = local_jscene_node_property_diff.jscene_property.property_value
        elif remote_jscene_node_property_diff != null:
            merged_jscene_property.property_name = remote_jscene_node_property_diff.jscene_property.property_name
            merged_jscene_property.property_value = remote_jscene_node_property_diff.jscene_property.property_value
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    elif is_deleted(merge_context):
        merged_jscene_property = null
        owner.properties.erase(self)
        if local_jscene_node_property_diff != null:
            local_jscene_node_property_diff.owner.properties.erase(local_jscene_node_property_diff)
        if remote_jscene_node_property_diff != null:
            remote_jscene_node_property_diff.owner.properties.erase(remote_jscene_node_property_diff)
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    else:
        push_error("Can not accept changes if modified or already merged")

func discard_changes(merge_context:int) -> void:
    if is_added(merge_context):
        merged_jscene_property = null
        owner.properties.erase(self)
        if local_jscene_node_property_diff != null:
            local_jscene_node_property_diff.owner.properties.erase(local_jscene_node_property_diff)
        if remote_jscene_node_property_diff != null:
            remote_jscene_node_property_diff.owner.properties.erase(remote_jscene_node_property_diff)
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    elif is_deleted(merge_context):
        if local_jscene_node_property_diff != null:
            merged_jscene_property.property_name = local_jscene_node_property_diff.jscene_property.property_name
            merged_jscene_property.property_value = local_jscene_node_property_diff.jscene_property.property_value
        elif remote_jscene_node_property_diff != null:
            merged_jscene_property.property_name = remote_jscene_node_property_diff.jscene_property.property_name
            merged_jscene_property.property_value = remote_jscene_node_property_diff.jscene_property.property_value
        merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED
    else:
        push_error("Can not discard changes if modified or already merged")

func accept_local_changes(merge_context:int) -> void:
    if not is_modified(merge_context):
        push_error("Can not accept local changes if not modified or already merge")
        return

    merged_jscene_property.property_name = local_jscene_node_property_diff.jscene_property.property_name
    merged_jscene_property.property_value = local_jscene_node_property_diff.jscene_property.property_value
    merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

func accept_remote_changes(merge_context:int) -> void:
    if not is_modified(merge_context):
        push_error("Can not accept local changes if not modified or already merge")
        return

    merged_jscene_property.property_name = remote_jscene_node_property_diff.jscene_property.property_name
    merged_jscene_property.property_value = remote_jscene_node_property_diff.jscene_property.property_value
    merge_status = JSceneMergeStatus.JSCENE_NODE_MERGE_STATUS_MERGED

#------------------------------------------
# Fonctions privées
#------------------------------------------

