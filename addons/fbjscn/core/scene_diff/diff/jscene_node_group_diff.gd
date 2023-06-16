extends RefCounted
class_name JSceneNodeGroupDiff

enum {
    JSCENE_NODE_DELTA_GROUP
}

var owner:JSceneNodeDiff
var jscene_group:JSceneNodeGroup

var delta_group:JSceneDelta

func has_delta() -> bool:
    return not delta_group.is_unchanged()
