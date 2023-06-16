@tool
extends Window
class_name ConflictingWindow

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var conflicting_scene:ConflictingScene

#------------------------------------------
# Variables privées
#------------------------------------------


var _tree_item_factory:TreeItemFactory = TreeItemFactory.new()
var _diff_manager:JsonSceneDiffManager = JsonSceneDiffManager.new()
var _merge_manager:JSceneMergeManager = JSceneMergeManager.new()

var _merged_scene:JSceneNodeMerge
var _total_pending_merge:int
var _total_treated_merge:int

@onready var local_tree:Tree = %LocalTree
@onready var remote_tree:Tree = %RemoteTree
@onready var merged_tree:Tree = %MergedTree
@onready var _conflict_label:Label = %ConflictsLabel
@onready var _merge_button:Button = %MergeButton

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _ready() -> void:
	var jscene_local:JSceneNode = JSceneConverter.to_jscene_node(conflicting_scene.json_scene_local)
	var jscene_remote:JSceneNode = JSceneConverter.to_jscene_node(conflicting_scene.json_scene_remote)

	var local_diff:JSceneNodeDiff = _diff_manager.diff(jscene_local, jscene_remote, JsonSceneDiffManager.DIFF_REF_LOCAL)
	var remote_diff:JSceneNodeDiff = _diff_manager.diff(jscene_remote, jscene_local, JsonSceneDiffManager.DIFF_REF_REMOTE)
	_merged_scene = _merge_manager.merge(local_diff, remote_diff)
	_total_pending_merge = _merged_scene.get_unmerged_changes_count()
	_total_treated_merge = 0

	_update_conflicts()

	_display_scene_diff(local_tree, local_diff)
	_display_scene_diff(remote_tree, remote_diff)
	_display_scene_merge(merged_tree, _merged_scene)

func _display_scene_merge(tree:Tree, merged_scene:JSceneNodeMerge) -> void:
	tree.clear()
	_recursive_display_scene_merge(tree, merged_scene, null)

func _recursive_display_scene_merge(tree:Tree, merged_scene:JSceneNodeMerge, parent_item:TreeItem) -> void:
	# Handle node itself
	var node_item:TreeItem = tree.create_item(parent_item)
	node_item.set_metadata(0, TreeItemMetadata.new(node_item, merged_scene))
	_set_merged_item_display(node_item)
	_set_merged_item_background_color(node_item)
	_set_merged_item_buttons(node_item)

	# Handle groups
	if not merged_scene.groups.is_empty():
		for group_merge in merged_scene.groups:
			var group_item:TreeItem = tree.create_item(node_item)
			group_item.set_metadata(0, TreeItemMetadata.new(group_item, group_merge))
			_set_merged_item_display(group_item)
			_set_merged_item_background_color(group_item)
			_set_merged_item_buttons(group_item)

	# Handle properties
	if not merged_scene.properties.is_empty():
		for prop_merge in merged_scene.properties:
			var prop_item:TreeItem = tree.create_item(node_item)
			prop_item.set_metadata(0, TreeItemMetadata.new(prop_item, prop_merge))
			_set_merged_item_display(prop_item)
			_set_merged_item_background_color(prop_item)
			_set_merged_item_buttons(prop_item)
			if prop_merge.is_merged():
				prop_item.collapsed = true

	# Handle connections
	if not merged_scene.connections.is_empty():
		for conn_merge in merged_scene.connections:
			var conn_item:TreeItem = tree.create_item(node_item)
			conn_item.set_metadata(0, TreeItemMetadata.new(conn_item, conn_merge, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION))
			_set_merged_item_display(conn_item, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION)
			_set_merged_item_background_color(conn_item)
			_set_merged_item_buttons(conn_item)

			# Sub-properties
			var conn_flags_item:TreeItem = tree.create_item(conn_item)
			conn_flags_item.set_metadata(0, TreeItemMetadata.new(conn_flags_item, conn_merge, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_FLAGS))
			_set_merged_item_display(conn_flags_item, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_FLAGS)
			_set_merged_item_background_color(conn_flags_item)
			_set_merged_item_buttons(conn_flags_item)

			var conn_target_path_item:TreeItem = tree.create_item(conn_item)
			conn_target_path_item.set_metadata(0, TreeItemMetadata.new(conn_target_path_item, conn_merge, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH))
			_set_merged_item_display(conn_target_path_item, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH)
			_set_merged_item_background_color(conn_target_path_item)
			_set_merged_item_buttons(conn_target_path_item)

			var conn_target_method_item:TreeItem = tree.create_item(conn_item)
			conn_target_method_item.set_metadata(0, TreeItemMetadata.new(conn_target_method_item, conn_merge, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD))
			_set_merged_item_display(conn_target_method_item, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD)
			_set_merged_item_background_color(conn_target_method_item)
			_set_merged_item_buttons(conn_target_method_item)

			var conn_binds_item:TreeItem = tree.create_item(conn_item)
			conn_binds_item.set_metadata(0, TreeItemMetadata.new(conn_binds_item, conn_merge, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_BINDS))
			_set_merged_item_display(conn_binds_item, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_BINDS)
			_set_merged_item_background_color(conn_binds_item)
			_set_merged_item_buttons(conn_binds_item)

			var conn_unbinds_item:TreeItem = tree.create_item(conn_item)
			conn_unbinds_item.set_metadata(0, TreeItemMetadata.new(conn_unbinds_item, conn_merge, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_UNBINDS))
			_set_merged_item_display(conn_unbinds_item, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_UNBINDS)
			_set_merged_item_background_color(conn_unbinds_item)
			_set_merged_item_buttons(conn_unbinds_item)

			# Collapse ?
			if conn_merge.is_merged():
				conn_item.collapsed = true

	# Handle children (recursion)
	for child in merged_scene.children:
		_recursive_display_scene_merge(tree, child, node_item)

func _display_scene_diff(tree:Tree, jscene_diff:JSceneNodeDiff) -> void:
	tree.clear()
	_recursive_display_scene_diff(tree, jscene_diff, null)

func _recursive_display_scene_diff(tree:Tree, jscene_diff:JSceneNodeDiff, parent_item:TreeItem) -> void:
	# Handle node itself
	var node_item:TreeItem = tree.create_item(parent_item)
	node_item.set_text(0, jscene_diff.jscene_node.node_name)
	node_item.set_icon(0, _tree_item_factory.get_type_icon(jscene_diff.jscene_node.node_type))
	node_item.set_metadata(0, TreeItemMetadata.new(node_item, jscene_diff))
	match jscene_diff.delta_node.delta_type:
		JSceneDelta.JSCENE_DELTA_ADDED:
			node_item.set_custom_color(0, Color.GREEN_YELLOW)
		JSceneDelta.JSCENE_DELTA_DELETED:
			node_item.set_custom_color(0, Color.ORANGE_RED)
		JSceneDelta.JSCENE_DELTA_MODIFIED:
			node_item.set_custom_color(0, Color.CORNFLOWER_BLUE)

	# Handle groups
	if not jscene_diff.groups.is_empty():
		for group_diff in jscene_diff.groups:
			var group_item:TreeItem = tree.create_item(node_item)
			group_item.set_text(0, group_diff.jscene_group.group_name)
			group_item.set_icon(0, _tree_item_factory.get_type_icon("Groups"))
			group_item.set_metadata(0, TreeItemMetadata.new(group_item, group_diff))
			match group_diff.delta_group.delta_type:
				JSceneDelta.JSCENE_DELTA_ADDED:
					group_item.set_custom_color(0, Color.GREEN_YELLOW)
				JSceneDelta.JSCENE_DELTA_DELETED:
					group_item.set_custom_color(0, Color.ORANGE_RED)

	# Handle properties
	if not jscene_diff.properties.is_empty():
		for prop_diff in jscene_diff.properties:
			var prop_item:TreeItem = tree.create_item(node_item)
			prop_item.set_text(0, "%s : %s" % [prop_diff.jscene_property.property_name, var_to_str(prop_diff.jscene_property.property_value)])
			prop_item.set_icon(0, _tree_item_factory.get_godot_type_icon(prop_diff.jscene_property.property_value))
			prop_item.set_metadata(0, TreeItemMetadata.new(prop_item, prop_diff))
			match prop_diff.delta_property.delta_type:
				JSceneDelta.JSCENE_DELTA_ADDED:
					prop_item.set_custom_color(0, Color.GREEN_YELLOW)
				JSceneDelta.JSCENE_DELTA_DELETED:
					prop_item.set_custom_color(0, Color.ORANGE_RED)
				JSceneDelta.JSCENE_DELTA_MODIFIED:
					prop_item.set_custom_color(0, Color.CORNFLOWER_BLUE)

	# Handle connections
	if not jscene_diff.connections.is_empty():
		for conn in jscene_diff.connections:
			var conn_item:TreeItem = tree.create_item(node_item)
			conn_item.set_text(0, conn.jscene_connection.signal_name)
			conn_item.set_icon(0, _tree_item_factory.get_type_icon("Signal"))
			conn_item.set_metadata(0, TreeItemMetadata.new(conn_item, conn, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION))
			match conn.delta_connection.delta_type:
				JSceneDelta.JSCENE_DELTA_ADDED:
					conn_item.set_custom_color(0, Color.GREEN_YELLOW)
				JSceneDelta.JSCENE_DELTA_DELETED:
					conn_item.set_custom_color(0, Color.ORANGE_RED)

			if conn.delta_connection.is_modified() or conn.delta_connection.is_unchanged():
				# Flags
				var conn_flags_item:TreeItem = tree.create_item(conn_item)
				conn_flags_item.set_text(0, "flags : %s" % conn.jscene_connection.connection_flags)
				conn_flags_item.set_custom_color(0, Color.CORNFLOWER_BLUE if conn.delta_connection_flags.is_modified() else Color.WHITE_SMOKE)
				conn_flags_item.set_metadata(0,  TreeItemMetadata.new(conn_flags_item, conn, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_FLAGS))
				conn_flags_item.set_icon(0, _tree_item_factory.get_type_icon("Enum"))
				# Target path
				var conn_target_path_item:TreeItem = tree.create_item(conn_item)
				conn_target_path_item.set_text(0, "target path : %s" % conn.jscene_connection.connection_target_path)
				conn_target_path_item.set_custom_color(0, Color.CORNFLOWER_BLUE if conn.delta_connection_target_path.is_modified() else Color.WHITE_SMOKE)
				conn_target_path_item.set_metadata(0,  TreeItemMetadata.new(conn_target_path_item, conn, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH))
				conn_target_path_item.set_icon(0, _tree_item_factory.get_type_icon("NodePath"))
				# Target methods
				var conn_target_method_item:TreeItem = tree.create_item(conn_item)
				conn_target_method_item.set_text(0, "method : %s" % conn.jscene_connection.connection_target_method_name)
				conn_target_method_item.set_custom_color(0, Color.CORNFLOWER_BLUE if conn.delta_connection_target_method.is_modified() else Color.WHITE_SMOKE)
				conn_target_method_item.set_metadata(0,  TreeItemMetadata.new(conn_target_method_item, conn, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD))
				conn_target_method_item.set_icon(0, _tree_item_factory.get_type_icon("String"))
				# Binds
				var conn_binds_item:TreeItem = tree.create_item(conn_item)
				conn_binds_item.set_text(0, "binds : [%s]" % [", ".join(conn.jscene_connection.connection_binds.map(func(b): return var_to_str(b)))])
				conn_binds_item.set_custom_color(0, Color.CORNFLOWER_BLUE if conn.delta_connection_binds.is_modified() else Color.WHITE_SMOKE)
				conn_binds_item.set_metadata(0,  TreeItemMetadata.new(conn_binds_item, conn, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_BINDS))
				conn_binds_item.set_icon(0, _tree_item_factory.get_type_icon("Array"))
				# Unbinds
				var conn_unbinds_item:TreeItem = tree.create_item(conn_item)
				conn_unbinds_item.set_text(0, "unbinds : %s" % conn.jscene_connection.connection_unbinds)
				conn_unbinds_item.set_custom_color(0, Color.CORNFLOWER_BLUE if conn.delta_connection_unbinds.is_modified() else Color.WHITE_SMOKE)
				conn_unbinds_item.set_metadata(0,  TreeItemMetadata.new(conn_unbinds_item, conn, JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_UNBINDS))
				conn_unbinds_item.set_icon(0, _tree_item_factory.get_type_icon("int"))

	# Handle children (recursion)
	for child in jscene_diff.children:
		_recursive_display_scene_diff(tree, child, node_item)

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _on_merged_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var merge_info = item.get_metadata(0).metadata
	var merge_context = item.get_metadata(0).context

	if id == 0:
		var is_deletion:bool = merge_info.is_deleted(merge_context)
		var merge_info_merge_count:int = merge_info.get_unmerged_changes_count() if merge_info is JSceneNodeMerge else 0
		merge_info.accept_changes(merge_context)
		if is_deletion:
			if merge_info is JSceneNodeMerge:
				_total_pending_merge -= merge_info_merge_count - 1
			merged_tree.erase_background_of_related_tree_items(item.get_metadata(0))
			item.free()
		else:
			_set_merged_item_background_color(item)
			_set_merged_item_buttons(item)
			_set_merged_item_display(item)
	elif id == 1:
		var is_added:bool = merge_info.is_added(merge_context)
		var merge_info_merge_count:int = merge_info.get_unmerged_changes_count() if merge_info is JSceneNodeMerge else 0
		merge_info.discard_changes(merge_context)
		if is_added:
			if merge_info is JSceneNodeMerge:
				_total_pending_merge -= merge_info_merge_count - 1
			merged_tree.erase_background_of_related_tree_items(item.get_metadata(0))
			item.free()
		else:
			_set_merged_item_background_color(item)
			_set_merged_item_buttons(item)
			_set_merged_item_display(item)
	elif id == 2:
		merge_info.accept_local_changes(merge_context)
		_set_merged_item_background_color(item)
		_set_merged_item_buttons(item)
		_set_merged_item_display(item)
	elif id == 3:
		merge_info.accept_remote_changes(merge_context)
		_set_merged_item_background_color(item)
		_set_merged_item_buttons(item)
		_set_merged_item_display(item)
	elif id == 4:
		merge_info.mark_as_merged(merge_context)
		_set_merged_item_background_color(item)
		_set_merged_item_buttons(item)
		_set_merged_item_display(item)

	_total_treated_merge += 1
	_update_conflicts()

func _on_close_requested() -> void:
	hide()
	queue_free()

func _set_merged_item_display(item:TreeItem, context:int = -1) -> void:
	var merge_info = item.get_metadata(0).metadata
	var merge_context = item.get_metadata(0).context

	if merge_info is JSceneNodeMerge:
		item.set_custom_font(0, _tree_item_factory.get_font())
		item.set_custom_font_size(0, 15)
		item.set_text(0, "%s (%s)%s" % [merge_info.get_displayed_node_name(), merge_info.get_displayed_node_type(), merge_info.get_displayed_node_position_changed()])
		item.set_icon(0, _tree_item_factory.get_type_icon(merge_info.get_displayed_node_type()))
	elif merge_info is JSceneNodeGroupMerge:
		item.set_custom_font(0, _tree_item_factory.get_italic_font())
		item.set_text(0, merge_info.get_displayed_group_name())
		item.set_icon(0, _tree_item_factory.get_type_icon("Groups"))
	elif merge_info is JSceneNodePropertyMerge:
		item.set_custom_font(0, _tree_item_factory.get_italic_font())
		item.set_text(0, "%s : %s" % [merge_info.get_displayed_property_name(), merge_info.get_displayed_property_value()])
		item.set_icon(0, _tree_item_factory.get_godot_type_icon(merge_info.get_displayed_property()))
	elif merge_info is JSceneNodeConnectionMerge:
		item.set_custom_font(0, _tree_item_factory.get_italic_font())
		if merge_context == JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION:
			item.set_text(0, merge_info.get_displayed_signal_name())
			item.set_icon(0, _tree_item_factory.get_type_icon("Signal"))
		elif merge_context == JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_FLAGS:
			item.set_text(0, "flags : %s" % merge_info.get_displayed_flags_value())
			item.set_icon(0, _tree_item_factory.get_type_icon("Enum"))
		elif merge_context == JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH:
			item.set_text(0, "target path: %s" % merge_info.get_displayed_target_path_value())
			item.set_icon(0, _tree_item_factory.get_type_icon("NodePath"))
		elif merge_context == JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD:
			item.set_text(0, "target method: %s" % merge_info.get_displayed_target_method_value())
			item.set_icon(0, _tree_item_factory.get_type_icon("String"))
		elif merge_context == JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_BINDS:
			item.set_text(0, "binds: %s" % merge_info.get_displayed_binds_value())
			item.set_icon(0, _tree_item_factory.get_type_icon("Array"))
		elif merge_context == JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_UNBINDS:
			item.set_text(0, "unbinds: %s" % merge_info.get_displayed_unbinds_value())
			item.set_icon(0, _tree_item_factory.get_type_icon("int"))

func _set_merged_item_background_color(item:TreeItem) -> void:
	var merge_info = item.get_metadata(0).metadata
	var merge_context = item.get_metadata(0).context
	if merge_info.is_added(merge_context):
		item.set_custom_bg_color(0, _get_modification_added_background_color())
	elif merge_info.is_deleted(merge_context):
		item.set_custom_bg_color(0, _get_modification_deleted_background_color())
	elif merge_info.is_modified(merge_context):
		item.set_custom_bg_color(0, _get_modification_modified_background_color())
	else:
		item.clear_custom_bg_color(0)

func _set_merged_item_buttons(item:TreeItem) -> void:
	var merge_info = item.get_metadata(0).metadata
	var merge_context = item.get_metadata(0).context
	if merge_info.is_added(merge_context) or merge_info.is_deleted(merge_context):
		item.add_button(0, _tree_item_factory.get_type_icon("StatusSuccess"), 0, false, "Accept changes")
		item.add_button(0, _tree_item_factory.get_type_icon("StatusError"), 1, false, "Discard changes")
	elif merge_info.is_modified(merge_context):
		if merge_info is JSceneNodeMerge and merge_info.is_only_position_modification(merge_context):
			item.add_button(0, _tree_item_factory.get_type_icon("StatusSuccess"), 4, false, "Mark as seen")
		else:
			item.add_button(0, _tree_item_factory.get_type_icon("MoveRight"), 2, false, "Accept local changes")
			item.add_button(0, _tree_item_factory.get_type_icon("MoveLeft"), 3, false, "Accept remote changes")
	else:
		var btn_count:int = item.get_button_count(0)
		if btn_count != 0:
			var accept_changes_btn_index:int = item.get_button_by_id(0, 0)
			if accept_changes_btn_index != -1:
				item.erase_button(0, accept_changes_btn_index)
			var discard_changes_btn_index:int = item.get_button_by_id(0, 1)
			if discard_changes_btn_index != -1:
				item.erase_button(0, discard_changes_btn_index)
			var accept_local_changes_btn_index:int = item.get_button_by_id(0, 2)
			if accept_local_changes_btn_index != -1:
				item.erase_button(0, accept_local_changes_btn_index)
			var accept_remote_changes_btn_index:int = item.get_button_by_id(0, 3)
			if accept_remote_changes_btn_index != -1:
				item.erase_button(0, accept_remote_changes_btn_index)
			var mark_merge_btn_index:int = item.get_button_by_id(0, 4)
			if mark_merge_btn_index != -1:
				item.erase_button(0, mark_merge_btn_index)


func _get_modification_added_background_color() -> Color:
	return Color("#ABEBC6", 0.3)

func _get_modification_modified_background_color() -> Color:
	return Color("#AED6F1", 0.3)

func _get_modification_deleted_background_color() -> Color:
	return Color("#EC7063", 0.3)

func _on_merged_tree_item_activated() -> void:
	var selected_item:TreeItem = merged_tree.get_selected()
	if selected_item:
		var metadata:Variant = selected_item.get_metadata(0).metadata
		var context:Variant = selected_item.get_metadata(0).context

		var edition_title:String
		var edition_value:Variant
		var edit_hint:int = EditingWindow.EDITING_HINT_NO_HINT

		if metadata is JSceneNodeGroupMerge:
			edition_title = "Group"
			edition_value = metadata.get_displayed_group_name()
		elif metadata is JSceneNodePropertyMerge:
			edition_title = metadata.get_displayed_property_name()
			edition_value = metadata.get_displayed_property()
		elif metadata is JSceneNodeConnectionMerge:
			match context:
				JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_FLAGS:
					edition_title = "Flags"
					edition_value = metadata.get_displayed_flags()
					edit_hint = EditingWindow.EDITING_HINT_CONNECTION_FLAGS
				JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH:
					edition_title = "Target Path"
					edition_value = metadata.get_displayed_target_path()
				JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD:
					edition_title = "Target Method Name"
					edition_value = metadata.get_displayed_target_method()
				JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_BINDS:
					edition_title = "Binds"
					edition_value = metadata.get_displayed_binds()
				JSceneNodeConnectionDiff.JSCENE_NODE_DELTA_CONNECTION_UNBINDS:
					edition_title = "Unbind"
					edition_value = metadata.get_displayed_unbinds()

		if not edition_title.is_empty():
			var popup:EditingWindow = preload("res://addons/fbjscn/ui/EditingWindow.tscn").instantiate()
			add_child(popup)
			popup.popup_centered()
			popup.edit(edition_title, edition_value, edit_hint)

			var res:Array[Variant] = await popup.on_close
			if res[0]: # Has been validated
				metadata.update_value(context, res[1])

				_total_treated_merge += 1
				_update_conflicts()

				_set_merged_item_background_color(selected_item)
				_set_merged_item_buttons(selected_item)
				_set_merged_item_display(selected_item)

func _update_conflicts() -> void:
	_conflict_label.text = "%s / %s" % [_total_treated_merge, _total_pending_merge]
	if _total_treated_merge == _total_pending_merge:
		_merge_button.disabled = false

func _on_merge_button_pressed() -> void:
	var merged_node:JSceneNode = merged_tree.get_root().get_metadata(0).metadata.get_consolidated_merged_node()
	print(JSON.stringify(merged_node.serialize(), "  ", false, true))
	hide()
	queue_free()

func _on_cancel_button_pressed() -> void:
	hide()
	queue_free()
