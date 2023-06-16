extends RefCounted
class_name TreeItemMetadata

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var metadata:Variant
var context:int

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _init(the_tree_item:TreeItem, the_metadata:Variant, the_context:int = -1) -> void:
	metadata = the_metadata
	context = the_context

	if the_metadata:
		if not the_metadata.has_meta("jscn_tree_items"):
			var the_typed_array:Array[TreeItem] = []
			the_metadata.set_meta("jscn_tree_items", the_typed_array)
		the_metadata.get_meta("jscn_tree_items").append(the_tree_item)

func get_context_related_tree_items(ctx:int) -> Array[TreeItem]:
	var items:Array[TreeItem] = []
	if metadata.has_meta("jscn_tree_items"):
		for item in metadata.get_meta("jscn_tree_items"):
			if item.get_metadata(0).context == ctx:
				items.append(item)
	return items
#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

