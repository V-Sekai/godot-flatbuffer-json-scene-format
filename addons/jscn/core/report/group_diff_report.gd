@tool
extends RefCounted
class_name GroupDiffReport

var group_name:String
var added:bool = false
var removed:bool = false

func has_diff() -> bool:
	return added or removed
