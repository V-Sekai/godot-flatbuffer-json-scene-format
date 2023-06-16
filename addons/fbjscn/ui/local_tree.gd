@tool
extends Tree

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _get_drag_data(at_position: Vector2) -> Variant:
	var selected_item:TreeItem = get_selected()
	if selected_item != null and selected_item.has_meta("jscn_meta"):
		var preview = Label.new()
		var metadata:Dictionary = selected_item.get_meta("jscn_meta")
		if metadata["type"] == "node":
			preview.text = metadata["node_name"]
		if metadata["type"] == "group":
			preview.text = metadata["group_name"]
		if metadata["type"] == "property":
			preview.text = metadata["property_name"]
		set_drag_preview(preview)
		return metadata
	return null

func _can_drop_data(at_position: Vector2, data) -> bool:
	return false

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

