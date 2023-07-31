@tool
extends RefCounted
class_name PropertiesDiffReport

var property_reports:Array[PropertyDiffReport] = []

func has_diff() -> bool:
	return property_reports.any(func(r): return r.has_diff())
