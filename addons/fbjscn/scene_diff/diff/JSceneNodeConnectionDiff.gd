extends RefCounted
class_name JSceneNodeConnectionDiff

enum {
    JSCENE_NODE_DELTA_CONNECTION,
    JSCENE_NODE_DELTA_CONNECTION_FLAGS,
    JSCENE_NODE_DELTA_CONNECTION_TARGET_PATH,
    JSCENE_NODE_DELTA_CONNECTION_TARGET_METHOD,
    JSCENE_NODE_DELTA_CONNECTION_BINDS,
    JSCENE_NODE_DELTA_CONNECTION_UNBINDS
}

var jscene_connection:JSceneNodeConnection
var owner:JSceneNodeDiff

var delta_connection:JSceneDelta
var delta_connection_flags:JSceneDelta
var delta_connection_target_path:JSceneDelta
var delta_connection_target_method:JSceneDelta
var delta_connection_binds:JSceneDelta
var delta_connection_unbinds:JSceneDelta
