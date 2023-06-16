@tool
extends RefCounted
class_name NodeDiffReport

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

# Expectation (local)
var expected_path:NodePath
var expected_type:String
var expected_index_in_parent:int

var found:bool = false

# In remote
var json_node:Dictionary
var node_path:NodePath
var index_in_parent:int

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

