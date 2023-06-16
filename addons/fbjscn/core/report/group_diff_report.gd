@tool
extends RefCounted
class_name GroupDiffReport

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var group_name:String
var added:bool = false
var removed:bool = false

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func has_diff() -> bool:
    return added or removed

#------------------------------------------
# Fonctions privées
#------------------------------------------
