@tool
extends RefCounted
class_name PropertyDiffReport

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var property_name:String
var property_value:String
var added:bool = false
var modified:bool = false
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
    return added or modified or removed


#------------------------------------------
# Fonctions privées
#------------------------------------------

