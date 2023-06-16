@tool
extends RefCounted
class_name GitHelper

const CONFLICT_BEGIN_TOKEN:String = "<<<<<<< "
const CONFLICT_MID_TOKEN:String = "======="
const CONFLICT_END_TOKEN:String = ">>>>>>> "

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

#------------------------------------------
# Fonctions publiques
#------------------------------------------

static func file_has_conflicts(path:String) -> bool:
    var file:FileAccess = FileAccess.open(path, FileAccess.READ)
    var lines:PackedStringArray = []
    while not file.eof_reached():
        lines.append(file.get_line())

    # At least 1 conflict
    var begin_token_found:bool = false
    var mid_token_found:bool = false
    var end_token_found:bool = false

    for line in lines:
        if line.begins_with(CONFLICT_BEGIN_TOKEN):
            begin_token_found = true
        if line.begins_with(CONFLICT_MID_TOKEN):
            if not mid_token_found and begin_token_found:
                mid_token_found = true
        if line.begins_with(CONFLICT_END_TOKEN):
            if not end_token_found and begin_token_found and mid_token_found:
                end_token_found = true

    return begin_token_found and mid_token_found and end_token_found


static func get_onflicting_scene(path:String) -> ConflictingScene:
    var conflicting_scene:ConflictingScene = ConflictingScene.new()

    var local_lines:Array[String] = []
    var remote_lines:Array[String] = []

    var file:FileAccess = FileAccess.open(path, FileAccess.READ)

    var begin_token_found:bool = false
    var mid_token_found:bool = false
    var end_token_found:bool = false

    while not file.eof_reached():
        var current_line:String = file.get_line()

        if not _is_git_merge_line(current_line):
            # Either there is no git conflicts, or a conflict has been encoutered
            if not begin_token_found and not mid_token_found and not end_token_found:
                # No conflicts, line is in both revisions
                local_lines.append(current_line)
                remote_lines.append(current_line)
            else:
                # Conflict has occured, put line where it belongs (local/remote)
                if begin_token_found:
                    # Go to local
                    local_lines.append(current_line)
                elif mid_token_found:
                    # Go to remote
                    remote_lines.append(current_line)
                elif end_token_found:
                    # End of conflict, line is both local and remote
                    end_token_found = false
                    local_lines.append(current_line)
                    remote_lines.append(current_line)
        else:
            # Consume this line since it's not valuable for result
            # Mark which token has been encoutered to process next lines
            begin_token_found = current_line.begins_with(CONFLICT_BEGIN_TOKEN)
            mid_token_found = current_line.begins_with(CONFLICT_MID_TOKEN)
            end_token_found = current_line.begins_with(CONFLICT_END_TOKEN)

    conflicting_scene.json_scene_local = str_to_var("\n".join(local_lines))
    conflicting_scene.json_scene_remote = str_to_var("\n".join(remote_lines))

    return conflicting_scene

#------------------------------------------
# Fonctions privées
#------------------------------------------

static func _is_git_merge_line(line:String) -> bool:
    return line.begins_with(CONFLICT_BEGIN_TOKEN) or line.begins_with(CONFLICT_MID_TOKEN) or line.begins_with(CONFLICT_END_TOKEN)
