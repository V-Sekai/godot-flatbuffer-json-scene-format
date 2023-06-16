extends RefCounted
class_name JSceneNodeConnection

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

var owner:JSceneNode
var signal_name:String
var connection_flags:int
var connection_target_path:NodePath
var connection_target_method_name:String
var connection_binds:Array[Variant]
var connection_unbinds:int

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

