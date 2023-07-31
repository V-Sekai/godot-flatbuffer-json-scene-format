@tool
extends RefCounted
class_name PropertyDiffReport

var property_name:String
var property_value:String
var added:bool = false
var modified:bool = false
var removed:bool = false

func has_diff() -> bool:
	return added or modified or removed
