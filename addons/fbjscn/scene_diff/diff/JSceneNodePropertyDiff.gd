extends RefCounted
class_name JSceneNodePropertyDiff

enum {
    JSCENE_NODE_DELTA_PROPERTY
}

var owner:JSceneNodeDiff
var jscene_property:JSceneNodeProperty

var delta_property:JSceneDelta

func has_delta() -> bool:
    return not delta_property.is_unchanged()
