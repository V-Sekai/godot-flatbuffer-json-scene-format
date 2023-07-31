extends Node2D

#------------------------------------------
# Signaux
#------------------------------------------

#------------------------------------------
# Exports
#------------------------------------------

@export var toto:PackedStringArray = []
@export var toto2:Dictionary = {}

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _ready() -> void:
	var content:String = FileAccess.get_file_as_string("res://addons/jscn/file.json")
	print(content)
	print(JSON.parse_string(content))

func _process(delta:float) -> void:
	pass

func _physics_process(delta:float) -> void:
	pass

#------------------------------------------
# Fonctions publiques
#------------------------------------------

#------------------------------------------
# Fonctions privées
#------------------------------------------

