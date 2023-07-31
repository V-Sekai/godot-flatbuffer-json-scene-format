@tool
extends Tree

const HOVER_COLOR_LOCAL_REMOTE:Color = Color("#E5E7E9", 0.2)
const HOVER_COLOR_MERGED:Color = Color("#5DADE2", 0.2)

var _tree_item_factory:TreeItemFactory = TreeItemFactory.new()
var _hovered_item:TreeItem
var _hovered_item_original_bg_color

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var to_item:TreeItem = get_item_at_position(event.position)
		if to_item != _hovered_item:
#            if _hovered_item != null and _hovered_item.get_button_count(0) > 0:
#                _hovered_item.erase_button(0, 0)
#            _hovered_item = to_item
#            if _hovered_item != null and _hovered_item.has_meta("jscn_meta"):
#                _hovered_item.add_button(0, preload("res://button.svg"), 0)
			if _hovered_item != null:
				_hovered_item.clear_custom_bg_color(0)
				if _hovered_item_original_bg_color and _hovered_item_original_bg_color != Color.BLACK \
						and _hovered_item.get_metadata(0) and not _hovered_item.get_metadata(0).metadata.is_merged():
					_hovered_item.set_custom_bg_color(0, _hovered_item_original_bg_color)
				erase_background_of_related_tree_items(_hovered_item.get_metadata(0))
			_hovered_item = to_item
			if _hovered_item != null:
				_hovered_item_original_bg_color = _hovered_item.get_custom_bg_color(0)
				_hovered_item.set_custom_bg_color(0, HOVER_COLOR_MERGED)
				_set_background_of_related_tree_items(_hovered_item.get_metadata(0))

func erase_background_of_related_tree_items(metadata:TreeItemMetadata) -> void:
	if metadata.metadata is JSceneNodeMerge:
		var merged_node:JSceneNodeMerge = metadata.metadata as JSceneNodeMerge
		if merged_node.local_jscene_node_diff != null:
			for item in merged_node.local_jscene_node_diff.get_meta("jscn_tree_items"):
				item.clear_custom_bg_color(0)
		if merged_node.remote_jscene_node_diff != null:
			for item in merged_node.remote_jscene_node_diff.get_meta("jscn_tree_items"):
				item.clear_custom_bg_color(0)

	if metadata.metadata is JSceneNodeGroupMerge:
		var merged_group:JSceneNodeGroupMerge = metadata.metadata as JSceneNodeGroupMerge
		if merged_group.local_jscene_node_group_diff != null:
			for item in merged_group.local_jscene_node_group_diff.get_meta("jscn_tree_items"):
				item.clear_custom_bg_color(0)
		if merged_group.remote_jscene_node_group_diff != null:
			for item in merged_group.remote_jscene_node_group_diff.get_meta("jscn_tree_items"):
				item.clear_custom_bg_color(0)

	if metadata.metadata is JSceneNodePropertyMerge:
		var merged_prop:JSceneNodePropertyMerge = metadata.metadata as JSceneNodePropertyMerge
		if merged_prop.local_jscene_node_property_diff != null:
			for item in merged_prop.local_jscene_node_property_diff.get_meta("jscn_tree_items"):
				item.clear_custom_bg_color(0)
		if merged_prop.remote_jscene_node_property_diff != null:
			for item in merged_prop.remote_jscene_node_property_diff.get_meta("jscn_tree_items"):
				item.clear_custom_bg_color(0)

	if metadata.metadata is JSceneNodeConnectionMerge:
		var merged_conn:JSceneNodeConnectionMerge = metadata.metadata as JSceneNodeConnectionMerge
		if merged_conn.local_jscene_node_connection_diff != null:
			for item in merged_conn.local_jscene_node_connection_diff.get_meta("jscn_tree_items"):
				if item.get_metadata(0).context == metadata.context:
					item.clear_custom_bg_color(0)
		if merged_conn.remote_jscene_node_connection_diff != null:
			for item in merged_conn.remote_jscene_node_connection_diff.get_meta("jscn_tree_items"):
				if item.get_metadata(0).context == metadata.context:
					item.clear_custom_bg_color(0)

func _set_background_of_related_tree_items(metadata:TreeItemMetadata) -> void:
	if metadata.metadata is JSceneNodeMerge:
		var merged_node:JSceneNodeMerge = metadata.metadata as JSceneNodeMerge
		if merged_node.local_jscene_node_diff != null:
			for item in merged_node.local_jscene_node_diff.get_meta("jscn_tree_items"):
				item.set_custom_bg_color(0, HOVER_COLOR_LOCAL_REMOTE)
				item.get_tree().scroll_to_item(item, true)
		if merged_node.remote_jscene_node_diff != null:
			for item in merged_node.remote_jscene_node_diff.get_meta("jscn_tree_items"):
				item.set_custom_bg_color(0, HOVER_COLOR_LOCAL_REMOTE)
				item.get_tree().scroll_to_item(item, true)

	if metadata.metadata is JSceneNodeGroupMerge:
		var merged_group:JSceneNodeGroupMerge = metadata.metadata as JSceneNodeGroupMerge
		if merged_group.local_jscene_node_group_diff != null:
			for item in merged_group.local_jscene_node_group_diff.get_meta("jscn_tree_items"):
				item.set_custom_bg_color(0, HOVER_COLOR_LOCAL_REMOTE)
				item.get_tree().scroll_to_item(item, true)
		if merged_group.remote_jscene_node_group_diff != null:
			for item in merged_group.remote_jscene_node_group_diff.get_meta("jscn_tree_items"):
				item.set_custom_bg_color(0, HOVER_COLOR_LOCAL_REMOTE)
				item.get_tree().scroll_to_item(item, true)

	if metadata.metadata is JSceneNodePropertyMerge:
		var merged_prop:JSceneNodePropertyMerge = metadata.metadata as JSceneNodePropertyMerge
		if merged_prop.local_jscene_node_property_diff != null:
			for item in merged_prop.local_jscene_node_property_diff.get_meta("jscn_tree_items"):
				item.set_custom_bg_color(0, HOVER_COLOR_LOCAL_REMOTE)
				item.get_tree().scroll_to_item(item, true)
		if merged_prop.remote_jscene_node_property_diff != null:
			for item in merged_prop.remote_jscene_node_property_diff.get_meta("jscn_tree_items"):
				item.set_custom_bg_color(0, HOVER_COLOR_LOCAL_REMOTE)
				item.get_tree().scroll_to_item(item, true)

	if metadata.metadata is JSceneNodeConnectionMerge:
		var merged_conn:JSceneNodeConnectionMerge = metadata.metadata as JSceneNodeConnectionMerge
		if merged_conn.local_jscene_node_connection_diff != null:
			for item in merged_conn.local_jscene_node_connection_diff.get_meta("jscn_tree_items"):
				if item.get_metadata(0).context == metadata.context:
					item.set_custom_bg_color(0, HOVER_COLOR_LOCAL_REMOTE)
					item.get_tree().scroll_to_item(item, true)
		if merged_conn.remote_jscene_node_connection_diff != null:
			for item in merged_conn.remote_jscene_node_connection_diff.get_meta("jscn_tree_items"):
				if item.get_metadata(0).context == metadata.context:
					item.set_custom_bg_color(0, HOVER_COLOR_LOCAL_REMOTE)
					item.get_tree().scroll_to_item(item, true)

func _on_button_clicked(item:TreeItem, column:int, id:int, mouse_button_index:int) -> void:
	item.free()

func _on_item_activated() -> void:
	var item:TreeItem = get_selected()
	if item:
		item.collapsed = !item.collapsed
