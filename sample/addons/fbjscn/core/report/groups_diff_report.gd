@tool
extends RefCounted
class_name GroupsDiffReport

var group_reports:Array[GroupDiffReport] = []

func has_diff() -> bool:
	return group_reports.any(func(r): return r.has_diff())
