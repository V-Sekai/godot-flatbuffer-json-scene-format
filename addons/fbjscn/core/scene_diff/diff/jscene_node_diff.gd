extends RefCounted
class_name JSceneNodeDiff

enum {
    JSCENE_NODE_DELTA_NODE,
    JSCENE_NODE_DELTA_NODE_NAME,
    JSCENE_NODE_DELTA_NODE_TYPE,
    JSCENE_NODE_DELTA_NODE_POSITION_IN_PARENT
}

var jscene_node:JSceneNode

var groups:Array[JSceneNodeGroupDiff]
var properties:Array[JSceneNodePropertyDiff]
var connections:Array[JSceneNodeConnectionDiff]

var parent_node:JSceneNodeDiff
var children:Array[JSceneNodeDiff]

var alternative_node_path:NodePath
var delta_node:JSceneDelta
var delta_node_name:JSceneDelta
var delta_node_type:JSceneDelta
var delta_node_position_in_parent:JSceneDelta

func has_delta() -> bool:
    return not (delta_node.is_unchanged() and delta_node_name.is_unchanged() \
        and delta_node_type.is_unchanged() and delta_node_position_in_parent.is_unchanged())

func get_parent_node_path() -> NodePath:
    if parent_node == null:
        return ^"."
    else:
        return parent_node.jscene_node.node_path

func get_parent_alternative_node_path() -> NodePath:
    if parent_node == null:
        return ^"."
    else:
        return parent_node.alternative_node_path

func get_node_absolute(expected_node_path:NodePath) -> JSceneNodeDiff:
    var root:JSceneNodeDiff = self
    while root.parent_node != null:
        root = root.parent_node

    return root._recursive_node_search(expected_node_path)

func _recursive_node_search(expected_node_path:NodePath) -> JSceneNodeDiff:
    if expected_node_path == alternative_node_path:
        return self

    for child in children:
        var found_node:JSceneNodeDiff = child._recursive_node_search(expected_node_path)
        if found_node != null:
            return found_node

    return null
