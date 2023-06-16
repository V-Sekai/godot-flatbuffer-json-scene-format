@tool
extends EditorPlugin

var loader:JsonSceneLoader
var saver:JsonSceneSaver

func _enter_tree() -> void:
    print("LOADING")
    Engine.set_meta("godot_editor_theme", get_editor_interface().get_base_control().theme)

    loader = JsonSceneLoader.new()
    saver = JsonSceneSaver.new()
    ResourceLoader.add_resource_format_loader(loader, true)
    ResourceSaver.add_resource_format_saver(saver, true)
    print("LOADED")

func _exit_tree() -> void:
    ResourceLoader.remove_resource_format_loader(loader)
    ResourceSaver.remove_resource_format_saver(saver)
    loader = null
    saver = null

    Engine.remove_meta("godot_editor_theme")
