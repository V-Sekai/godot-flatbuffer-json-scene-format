extends RefCounted
class_name JSceneDelta

enum {
    JSCENE_DELTA_ADDED,
    JSCENE_DELTA_MODIFIED,
    JSCENE_DELTA_DELETED,
    JSCENE_DELTA_UNCHANGED
}

var delta_context:int

var delta_type:int = JSCENE_DELTA_UNCHANGED
var original:Variant
var other:Variant

func _init(context:int) -> void:
    delta_context = context

func is_added() -> bool:
    return delta_type == JSCENE_DELTA_ADDED

func is_modified() -> bool:
    return delta_type == JSCENE_DELTA_MODIFIED

func is_deleted() -> bool:
    return delta_type == JSCENE_DELTA_DELETED

func is_unchanged() -> bool:
    return delta_type == JSCENE_DELTA_UNCHANGED
