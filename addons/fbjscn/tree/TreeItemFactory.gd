@tool
extends RefCounted
class_name TreeItemFactory

var _editor_theme:Theme

func _init() -> void:
	_editor_theme = Engine.get_meta("godot_editor_theme")

func create_merge_tree_recursive(tree:Tree, node_name:String, json_node:Dictionary, parent_item:TreeItem) -> void:
	var item:TreeItem = create_merge_tree_item(tree, parent_item, node_name, json_node)
	if json_node.has("children"):
		for child_name in json_node["children"].keys():
			create_merge_tree_recursive(tree, child_name, json_node["children"][child_name], item)

func create_merge_tree_item(tree:Tree, parent_item:TreeItem, node_name:String, json_node:Dictionary, index:int = -1) -> TreeItem:
	var node_item:TreeItem = create_merged_node_tree_item(tree, node_name, json_node, parent_item, index)
	create_merged_node_group_tree_items(tree, json_node, node_item)
	create_merged_node_property_tree_items(tree, json_node, node_item)

	return node_item

func create_merged_node_tree_item(tree:Tree, node_name:String, json_node:Dictionary, parent_item:TreeItem, index:int = -1) -> TreeItem:
	var item:TreeItem = create_raw_node_tree_item(tree, node_name, json_node["type"], parent_item, index)
	item.set_meta("jscn_meta", {
		"type" : "node",
		"node_name" : node_name,
		"node" : json_node
	})
	return item

func create_merged_node_group_tree_items(tree:Tree, json_node:Dictionary, parent_item:TreeItem) -> void:
	if json_node.has("groups") and not json_node["groups"].is_empty():
		var group_item:TreeItem = tree.create_item(parent_item)
		group_item.set_text(0, "Groups")
		group_item.set_icon(0, get_type_icon("Groups"))

		json_node["groups"].sort()
		for group_name in json_node["groups"]:
			var item_group:TreeItem = create_raw_node_group_tree_item(tree, group_name, group_item)
			item_group.set_meta("jscn_meta", {
				"type" : "group",
				"group_name" : group_name,
			})

func create_merged_node_property_tree_items(tree:Tree, json_node:Dictionary, parent_item:TreeItem) -> void:
	if json_node.has("properties") and not json_node["properties"].is_empty():
		var properties_item:TreeItem = tree.create_item(parent_item)
		properties_item.set_text(0, "Properties")

		var sorted_keys:Array = json_node["properties"].keys()
		sorted_keys.sort()
		var sorted_properties:Dictionary = {}
		for key in sorted_keys:
			sorted_properties[key] = json_node["properties"][key]
		json_node["properties"] = sorted_properties

		for prop_name in json_node["properties"]:
			var item_prop:TreeItem = create_raw_node_property_tree_item(tree, prop_name, json_node["properties"][prop_name], properties_item)
			item_prop.set_meta("jscn_meta", {
				"type" : "property",
				"property_name" : prop_name,
				"property_value" : json_node["properties"][prop_name]
			})




func create_tree_recursive(tree:Tree, node_name:String, json_node:Dictionary, parent_item:TreeItem, is_local_ref:bool) -> void:
	var item:TreeItem = create_tree_item(tree, parent_item, node_name, json_node, is_local_ref)
	if json_node.has("children"):
		for child_name in json_node["children"].keys():
			create_tree_recursive(tree, child_name, json_node["children"][child_name], item, is_local_ref)

func create_tree_item(tree:Tree, parent_item:TreeItem, node_name:String, json_node:Dictionary, is_local_ref:bool, index:int = -1) -> TreeItem:
	var node_item:TreeItem = create_node_tree_item(tree, node_name, json_node, parent_item, is_local_ref, index)
	create_node_group_tree_items(tree, json_node, node_item)
	create_node_property_tree_items(tree, json_node, node_item)

	return node_item

func create_node_tree_item(tree:Tree, node_name:String, json_node:Dictionary, parent_item:TreeItem, is_local_ref:bool, index:int = -1) -> TreeItem:
	var item:TreeItem = create_raw_node_tree_item(tree, node_name, json_node["type"], parent_item, index)
	item.set_meta("jscn_meta", {
		"type" : "node",
		"node_name" : node_name,
		"node" : json_node
	})

	var report:NodeDiffReport = json_node.get("node_diff_report", null)
	if report:
		if not report.found:
			if is_local_ref:
				item.set_custom_color(0, Color.INDIAN_RED)
			else:
				item.set_custom_color(0, Color.GREEN_YELLOW)
		else:
			var moved:bool = report.found and (report.expected_path != report.node_path or report.expected_index_in_parent != report.index_in_parent)
			if moved:
				item.set_custom_color(0, Color.CORNFLOWER_BLUE)

	return item

func create_raw_node_tree_item(tree:Tree, node_name:String, node_type:String, parent_item:TreeItem, item_index:int = -1) -> TreeItem:
	var item_node:TreeItem = tree.create_item(parent_item, item_index)
	item_node.set_text(0, node_name)
	item_node.set_icon(0, get_type_icon(node_type))
	return item_node

func create_node_group_tree_items(tree:Tree, json_node:Dictionary, parent_item:TreeItem) -> void:
	if json_node.has("groups_diff_report"):
		var group_diff_report:GroupsDiffReport = json_node["groups_diff_report"]

		if not group_diff_report.group_reports.is_empty():
			var group_item:TreeItem = tree.create_item(parent_item)
			group_item.set_text(0, "Groups")
			group_item.set_icon(0, get_type_icon("Groups"))

			for group_report in group_diff_report.group_reports:
				var item_group:TreeItem = create_raw_node_group_tree_item(tree, group_report.group_name, group_item)
				item_group.set_meta("jscn_meta", {
					"type" : "group",
					"group_name" : group_report.group_name,
				})

				if group_report.has_diff():
					if group_report.added:
						item_group.set_custom_color(0, Color.GREEN_YELLOW)
					if group_report.removed:
						item_group.set_custom_color(0, Color.INDIAN_RED)

func create_raw_node_group_tree_item(tree:Tree, group_name:String, parent_item:TreeItem, item_index:int = -1) -> TreeItem:
	var item_group:TreeItem = tree.create_item(parent_item, item_index)
	item_group.set_text(0, group_name)
	return item_group

func create_node_property_tree_items(tree:Tree, json_node:Dictionary, parent_item:TreeItem) -> void:
	if json_node.has("properties_diff_report"):
		var property_diff_report:PropertiesDiffReport = json_node["properties_diff_report"]

		if not property_diff_report.property_reports.is_empty():
			var properties_item:TreeItem = tree.create_item(parent_item)
			properties_item.set_text(0, "Properties")

			for prop_report in property_diff_report.property_reports:
				var item_prop:TreeItem = create_raw_node_property_tree_item(tree, prop_report.property_name, prop_report.property_value, properties_item)
				item_prop.set_meta("jscn_meta", {
					"type" : "property",
					"property_name" : prop_report.property_name,
					"property_value" : prop_report.property_value,
				})
				if prop_report.added:
					item_prop.set_custom_color(0, Color.GREEN_YELLOW)
				if prop_report.modified:
					item_prop.set_custom_color(0, Color.CORNFLOWER_BLUE)
				if prop_report.removed:
					item_prop.set_custom_color(0, Color.INDIAN_RED)

				if prop_report.property_name == "script":
					item_prop.set_icon(0, get_type_icon("Script"))

func create_raw_node_property_tree_item(tree:Tree, property_name:String, property_value:String, parent_item:TreeItem, item_index:int = -1) -> TreeItem:
	var item_property:TreeItem = tree.create_item(parent_item, item_index)
	item_property.set_text(0, property_name + " : " + property_value)
	return item_property


func get_type_icon(type_name:String) -> Texture:
	if _editor_theme.has_icon(type_name, "EditorIcons"):
		return _editor_theme.get_icon(type_name, "EditorIcons")
	return _editor_theme.get_icon("ErrorWarning", "EditorIcons")

func get_godot_type_icon(value:Variant) -> Texture2D:
	match typeof(value):
		TYPE_NIL:
			return get_type_icon("Nil")
		TYPE_BOOL:
			return get_type_icon("bool")
		TYPE_INT:
			return get_type_icon("int")
		TYPE_FLOAT:
			return get_type_icon("float")
		TYPE_STRING:
			return get_type_icon("String")
		TYPE_VECTOR2:
			return get_type_icon("Vector2")
		TYPE_VECTOR2I:
			return get_type_icon("Vevtor2i")
		TYPE_RECT2:
			return get_type_icon("Rect2")
		TYPE_RECT2I:
			return get_type_icon("Rect2i")
		TYPE_VECTOR3:
			return get_type_icon("Vector3")
		TYPE_VECTOR3I:
			return get_type_icon("Vector3i")
		TYPE_TRANSFORM2D:
			return get_type_icon("Transform2D")
		TYPE_VECTOR4:
			return get_type_icon("Vector4")
		TYPE_VECTOR4I:
			return get_type_icon("Vector4i")
		TYPE_PLANE:
			return get_type_icon("Plane")
		TYPE_QUATERNION:
			return get_type_icon("Quaternion")
		TYPE_AABB:
			return get_type_icon("AABB")
		TYPE_BASIS:
			return get_type_icon("Basis")
		TYPE_TRANSFORM3D:
			return get_type_icon("Transform3D")
		TYPE_PROJECTION:
			return get_type_icon("Projection")
		TYPE_COLOR:
			return get_type_icon("Color")
		TYPE_STRING_NAME:
			return get_type_icon("StringName")
		TYPE_NODE_PATH:
			return get_type_icon("NodePath")
		TYPE_OBJECT:
			return get_type_icon(value.get_class())
		TYPE_CALLABLE:
			return get_type_icon("Callable")
		TYPE_SIGNAL:
			return get_type_icon("Signal")
		TYPE_DICTIONARY:
			return get_type_icon("Dictionary")
		TYPE_ARRAY:
			return get_type_icon("Array")
		TYPE_PACKED_BYTE_ARRAY:
			return get_type_icon("PackedByteArray")
		TYPE_PACKED_INT32_ARRAY:
			return get_type_icon("PackedInt32Array")
		TYPE_PACKED_INT64_ARRAY:
			return get_type_icon("PackedInt64Array")
		TYPE_PACKED_FLOAT32_ARRAY:
			return get_type_icon("PackedFloat32Array")
		TYPE_PACKED_FLOAT64_ARRAY:
			return get_type_icon("PackedFloat64Array")
		TYPE_PACKED_STRING_ARRAY:
			return get_type_icon("PackedStringArray")
		TYPE_PACKED_VECTOR2_ARRAY:
			return get_type_icon("PackedVector2Array")
		TYPE_PACKED_VECTOR3_ARRAY:
			return get_type_icon("PackedVector3Array")
		TYPE_PACKED_COLOR_ARRAY:
			return get_type_icon("PackedColorArray")
		_:
			return get_type_icon("ErrorWarning")

func get_font() -> Font:
	return _editor_theme.get_font("main", "EditorFonts")

func get_italic_font() -> Font:
	return _editor_theme.get_font("output_source_italic", "EditorFonts")
