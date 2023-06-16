@tool
extends Window
class_name EditingWindow

enum {
    EDITING_HINT_NO_HINT = 0,
    EDITING_HINT_CONNECTION_FLAGS = 2
}
#------------------------------------------
# Signaux
#------------------------------------------

signal on_close(is_validation:bool, value:Variant)

#------------------------------------------
# Exports
#------------------------------------------

#------------------------------------------
# Variables publiques
#------------------------------------------

#------------------------------------------
# Variables privées
#------------------------------------------

@onready var _background_color:ColorRect = %BackgroundColor
@onready var _control_panel:Control = %ControlPanel
@onready var _type_title:Label = %TypeTitle
@onready var _type_icon:TextureRect = %TypeIcon

var _tree_item_factory:TreeItemFactory = TreeItemFactory.new()
var _editor_theme:Theme
var _edition_control:EditionControl

#------------------------------------------
# Fonctions Godot redéfinies
#------------------------------------------

func _ready() -> void:
    _editor_theme = Engine.get_meta("godot_editor_theme")
    _background_color.color = _editor_theme.get_color("background", "Editor")

#------------------------------------------
# Fonctions publiques
#------------------------------------------

func edit(title:String, value:Variant, hint:int = EDITING_HINT_NO_HINT) -> void:
    _type_title.text = title
    _type_icon.texture = _tree_item_factory.get_godot_type_icon(value)
    _edition_control = _get_edition_control(value, hint)
    if _edition_control != null:
        _control_panel.add_child(_edition_control.get_control())
    child_controls_changed()

#------------------------------------------
# Fonctions privées
#------------------------------------------

func _get_edition_control(value:Variant, hint:int = EDITING_HINT_NO_HINT) -> EditionControl:
    if hint == EDITING_HINT_CONNECTION_FLAGS:
        return ConnectionFlagsEditionControl.new(value)
    match typeof(value):
        TYPE_NIL:
            pass
        TYPE_BOOL:
            return BoolEditionControl.new(value)
        TYPE_INT:
            return NumberEditionControl.new(value, false)
        TYPE_FLOAT:
            return NumberEditionControl.new(value, true)
        TYPE_STRING:
            return MultiLineStringEditionControl.new(value)
        TYPE_VECTOR2:
            return Vector2EditionControl.new(value, true)
        TYPE_VECTOR2I:
            return Vector2EditionControl.new(value, false)
        TYPE_RECT2:
            return Rect2EditionControl.new(value, true)
        TYPE_RECT2I:
            return Rect2EditionControl.new(value, false)
        TYPE_VECTOR3:
            return Vector3EditionControl.new(value, true)
        TYPE_VECTOR3I:
            return Vector3EditionControl.new(value, false)
        TYPE_TRANSFORM2D:
            return Transform2DEditionControl.new(value)
        TYPE_VECTOR4:
            return Vector4EditionControl.new(value, true)
        TYPE_VECTOR4I:
            return Vector4EditionControl.new(value, false)
        TYPE_PLANE:
            return PlaneEditionControl.new(value)
        TYPE_QUATERNION:
            return QuaternionEditionControl.new(value)
        TYPE_AABB:
            return AABBEditionControl.new(value)
        TYPE_BASIS:
            return BasisEditionControl.new(value)
        TYPE_TRANSFORM3D:
            return Transform3DEditionControl.new(value)
        TYPE_PROJECTION:
            return ProjectionEditionControl.new(value)
        TYPE_COLOR:
            return ColorEditionControl.new(value)
        TYPE_STRING_NAME:
            return MonoLineStringEditionControl.new(value, func(val): return val, func(str): return StringName(str))
        TYPE_NODE_PATH:
            return MonoLineStringEditionControl.new(value, func(val): return val, func(str): return NodePath(str))
        TYPE_OBJECT:
            pass
        TYPE_CALLABLE:
            pass
        TYPE_SIGNAL:
            pass
        TYPE_DICTIONARY:
            pass
        TYPE_ARRAY:
            pass
        TYPE_PACKED_BYTE_ARRAY:
            pass
        TYPE_PACKED_INT32_ARRAY:
            pass
        TYPE_PACKED_INT64_ARRAY:
            pass
        TYPE_PACKED_FLOAT32_ARRAY:
            pass
        TYPE_PACKED_FLOAT64_ARRAY:
            pass
        TYPE_PACKED_STRING_ARRAY:
            pass
        TYPE_PACKED_VECTOR2_ARRAY:
            pass
        TYPE_PACKED_VECTOR3_ARRAY:
            pass
        TYPE_PACKED_COLOR_ARRAY:
            pass

    return MonoLineStringEditionControl.new(value, func(val): return var_to_str(val), func(str): return str_to_var(str))

class EditionControl extends RefCounted:
    func get_control() -> Control:
        return null

    func get_value() -> Variant:
        return null

class ConnectionFlagsEditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _check_deferred:CheckBox
    var _check_persist:CheckBox
    var _check_oneshot:CheckBox
    var _check_refcounted:CheckBox

    func _init(value:Variant) -> void:
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _check_deferred = CheckBox.new()
        _check_deferred.button_pressed = value & CONNECT_DEFERRED == CONNECT_DEFERRED
        _check_deferred.text = "CONNECT_DEFERRED"
        _check_deferred.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_check_deferred)

        _check_persist = CheckBox.new()
        _check_persist.button_pressed = value & CONNECT_PERSIST == CONNECT_PERSIST
        _check_persist.text = "CONNECT_PERSIST"
        _check_persist.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_check_persist)

        _check_oneshot = CheckBox.new()
        _check_oneshot.button_pressed = value & CONNECT_ONE_SHOT == CONNECT_ONE_SHOT
        _check_oneshot.text = "CONNECT_ONE_SHOT"
        _check_oneshot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_check_oneshot)

        _check_refcounted = CheckBox.new()
        _check_refcounted.button_pressed = value & CONNECT_REFERENCE_COUNTED == CONNECT_REFERENCE_COUNTED
        _check_refcounted.text = "CONNECT_REFERENCE_COUNTED"
        _check_refcounted.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_check_refcounted)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return (CONNECT_DEFERRED if _check_deferred.button_pressed else 0) \
                | (CONNECT_PERSIST if _check_persist.button_pressed else 0) \
                | (CONNECT_ONE_SHOT if _check_oneshot.button_pressed else 0) \
                | (CONNECT_REFERENCE_COUNTED if _check_refcounted.button_pressed else 0)

class BoolEditionControl extends EditionControl:

    var _check:CheckBox

    func _init(value:Variant) -> void:
        _check = CheckBox.new()
        _check.button_pressed = value
        _check.text = tr("On")
        _check.tooltip_text = str(_check.button_pressed)
        _check.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    func get_control() -> Control:
        return _check

    func get_value() -> Variant:
        return _check.button_pressed

class NumberEditionControl extends EditionControl:

    var _spin:SpinBox

    func _init(value:Variant, float_mode:bool) -> void:
        _spin = SpinBox.new()
        _spin.min_value = -9999999999
        _spin.max_value = 9999999999
        _spin.step = 0.001 if float_mode else 1
        _spin.value = value
        _spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    func get_control() -> Control:
        return _spin

    func get_value() -> Variant:
        return _spin.value

class MonoLineStringEditionControl extends EditionControl:

    var _line_edit:LineEdit
    var _value_to_str_transformer:Callable
    var _str_to_value_transformer:Callable

    func _init(value:Variant, value_to_str_transformer:Callable, str_to_value_transformer:Callable) -> void:
        _value_to_str_transformer = value_to_str_transformer
        _str_to_value_transformer = str_to_value_transformer
        _line_edit = LineEdit.new()
        _line_edit.text = _value_to_str_transformer.call(value)
        _line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    func get_control() -> Control:
        return _line_edit

    func get_value() -> Variant:
        return _str_to_value_transformer.call(_line_edit.text)

class MultiLineStringEditionControl extends EditionControl:

    var _text_edit:TextEdit

    func _init(value:Variant) -> void:
        _text_edit = TextEdit.new()
        _text_edit.text = value
        _text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
        _text_edit.custom_minimum_size = Vector2(160, 150)
        _text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _text_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL

    func get_control() -> Control:
        return _text_edit

    func get_value() -> Variant:
        return _text_edit.text

class Vector2EditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_x:SpinBox
    var _spin_y:SpinBox
    var _float_mode:bool

    func _init(value:Variant, float_mode:bool) -> void:
        _float_mode = float_mode
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_x = SpinBox.new()
        _spin_x.prefix = "x"
        _spin_x.min_value = -9999999999
        _spin_x.max_value = 9999999999
        _spin_x.step = 0.001 if float_mode else 1
        _spin_x.value = value.x
        _spin_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_x)

        _spin_y = SpinBox.new()
        _spin_y.prefix = "y"
        _spin_y.min_value = -9999999999
        _spin_y.max_value = 9999999999
        _spin_y.step = 0.001 if float_mode else 1
        _spin_y.value = value.y
        _spin_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_y)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return Vector2(_spin_x.value, _spin_y.value) if _float_mode else Vector2i(_spin_x.value, _spin_y.value)

class Vector3EditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_x:SpinBox
    var _spin_y:SpinBox
    var _spin_z:SpinBox
    var _float_mode:bool

    func _init(value:Variant, float_mode:bool) -> void:
        _float_mode = float_mode
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_x = SpinBox.new()
        _spin_x.prefix = "x"
        _spin_x.min_value = -9999999999
        _spin_x.max_value = 9999999999
        _spin_x.step = 0.001 if float_mode else 1
        _spin_x.value = value.x
        _spin_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_x)

        _spin_y = SpinBox.new()
        _spin_y.prefix = "y"
        _spin_y.min_value = -9999999999
        _spin_y.max_value = 9999999999
        _spin_y.step = 0.001 if float_mode else 1
        _spin_y.value = value.y
        _spin_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_y)

        _spin_z = SpinBox.new()
        _spin_z.prefix = "z"
        _spin_z.min_value = -9999999999
        _spin_z.max_value = 9999999999
        _spin_z.step = 0.001 if float_mode else 1
        _spin_z.value = value.z
        _spin_z.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_z)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return Vector3(_spin_x.value, _spin_y.value, _spin_z.value) if _float_mode else Vector3i(_spin_x.value, _spin_y.value, _spin_z.value)

class Vector4EditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_x:SpinBox
    var _spin_y:SpinBox
    var _spin_z:SpinBox
    var _spin_w:SpinBox
    var _float_mode:bool

    func _init(value:Variant, float_mode:bool) -> void:
        _float_mode = float_mode
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_x = SpinBox.new()
        _spin_x.prefix = "x"
        _spin_x.min_value = -9999999999
        _spin_x.max_value = 9999999999
        _spin_x.step = 0.001 if float_mode else 1
        _spin_x.value = value.x
        _spin_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_x)

        _spin_y = SpinBox.new()
        _spin_y.prefix = "y"
        _spin_y.min_value = -9999999999
        _spin_y.max_value = 9999999999
        _spin_y.step = 0.001 if float_mode else 1
        _spin_y.value = value.y
        _spin_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_y)

        _spin_z = SpinBox.new()
        _spin_z.prefix = "z"
        _spin_z.min_value = -9999999999
        _spin_z.max_value = 9999999999
        _spin_z.step = 0.001 if float_mode else 1
        _spin_z.value = value.z
        _spin_z.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_z)

        _spin_w = SpinBox.new()
        _spin_w.prefix = "w"
        _spin_w.min_value = -9999999999
        _spin_w.max_value = 9999999999
        _spin_w.step = 0.001 if float_mode else 1
        _spin_w.value = value.w
        _spin_w.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_w)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return Vector4(_spin_x.value, _spin_y.value, _spin_z.value, _spin_w.value) if _float_mode else Vector4i(_spin_x.value, _spin_y.value, _spin_z.value, _spin_w.value)

class Rect2EditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_x:SpinBox
    var _spin_y:SpinBox
    var _spin_w:SpinBox
    var _spin_h:SpinBox
    var _float_mode:bool

    func _init(value:Variant, float_mode:bool) -> void:
        _float_mode = float_mode
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_x = SpinBox.new()
        _spin_x.prefix = "x"
        _spin_x.min_value = -9999999999
        _spin_x.max_value = 9999999999
        _spin_x.step = 0.001 if float_mode else 1
        _spin_x.value = value.position.x
        _spin_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_x)

        _spin_y = SpinBox.new()
        _spin_y.prefix = "y"
        _spin_y.min_value = -9999999999
        _spin_y.max_value = 9999999999
        _spin_y.step = 0.001 if float_mode else 1
        _spin_y.value = value.position.y
        _spin_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_y)

        _spin_w = SpinBox.new()
        _spin_w.prefix = "w"
        _spin_w.min_value = -9999999999
        _spin_w.max_value = 9999999999
        _spin_w.step = 0.001 if float_mode else 1
        _spin_w.value = value.size.x
        _spin_w.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_w)

        _spin_h = SpinBox.new()
        _spin_h.prefix = "w"
        _spin_h.min_value = -9999999999
        _spin_h.max_value = 9999999999
        _spin_h.step = 0.001 if float_mode else 1
        _spin_h.value = value.size.y
        _spin_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_h)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return Rect2(_spin_x.value, _spin_y.value, _spin_w.value, _spin_h.value) if _float_mode else Rect2i(_spin_x.value, _spin_y.value, _spin_w.value, _spin_h.value)

class Transform2DEditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_xx:SpinBox
    var _spin_xy:SpinBox
    var _spin_xo:SpinBox
    var _spin_yx:SpinBox
    var _spin_yy:SpinBox
    var _spin_yo:SpinBox

    func _init(value:Variant) -> void:
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_xx = SpinBox.new()
        _spin_xx.prefix = "xx"
        _spin_xx.min_value = -9999999999
        _spin_xx.max_value = 9999999999
        _spin_xx.step = 0.001
        _spin_xx.value = value.x.x
        _spin_xx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xx)

        _spin_xy = SpinBox.new()
        _spin_xy.prefix = "xy"
        _spin_xy.min_value = -9999999999
        _spin_xy.max_value = 9999999999
        _spin_xy.step = 0.001
        _spin_xy.value = value.x.y
        _spin_xy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xy)

        _spin_xo = SpinBox.new()
        _spin_xo.prefix = "xo"
        _spin_xo.min_value = -9999999999
        _spin_xo.max_value = 9999999999
        _spin_xo.step = 0.001
        _spin_xo.value = value.y.x
        _spin_xo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xo)

        _spin_yx = SpinBox.new()
        _spin_yx.prefix = "xy"
        _spin_yx.min_value = -9999999999
        _spin_yx.max_value = 9999999999
        _spin_yx.step = 0.001
        _spin_yx.value = value.y.y
        _spin_yx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yx)

        _spin_yy = SpinBox.new()
        _spin_yy.prefix = "yy"
        _spin_yy.min_value = -9999999999
        _spin_yy.max_value = 9999999999
        _spin_yy.step = 0.001
        _spin_yy.value = value.origin.x
        _spin_yy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yy)

        _spin_yo = SpinBox.new()
        _spin_yo.prefix = "yo"
        _spin_yo.min_value = -9999999999
        _spin_yo.max_value = 9999999999
        _spin_yo.step = 0.001
        _spin_yo.value = value.origin.y
        _spin_yo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yo)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return Transform2D(Vector2(_spin_xx.value, _spin_xy.value), Vector2(_spin_yx.value, _spin_yy.value), Vector2(_spin_xo.value, _spin_yo.value))

class PlaneEditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_x:SpinBox
    var _spin_y:SpinBox
    var _spin_z:SpinBox
    var _spin_d:SpinBox

    func _init(value:Variant) -> void:
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_x = SpinBox.new()
        _spin_x.prefix = "x"
        _spin_x.min_value = -9999999999
        _spin_x.max_value = 9999999999
        _spin_x.step = 0.001
        _spin_x.value = value.x
        _spin_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_x)

        _spin_y = SpinBox.new()
        _spin_y.prefix = "y"
        _spin_y.min_value = -9999999999
        _spin_y.max_value = 9999999999
        _spin_y.step = 0.001
        _spin_y.value = value.y
        _spin_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_y)

        _spin_z = SpinBox.new()
        _spin_z.prefix = "z"
        _spin_z.min_value = -9999999999
        _spin_z.max_value = 9999999999
        _spin_z.step = 0.001
        _spin_z.value = value.z
        _spin_z.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_z)

        _spin_d = SpinBox.new()
        _spin_d.prefix = "d"
        _spin_d.min_value = -9999999999
        _spin_d.max_value = 9999999999
        _spin_d.step = 0.001
        _spin_d.value = value.d
        _spin_d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_d)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return Plane(_spin_x.value, _spin_y.value, _spin_z.value, _spin_d.value)

class QuaternionEditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_x:SpinBox
    var _spin_y:SpinBox
    var _spin_z:SpinBox
    var _spin_w:SpinBox

    func _init(value:Variant) -> void:
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_x = SpinBox.new()
        _spin_x.prefix = "x"
        _spin_x.min_value = -9999999999
        _spin_x.max_value = 9999999999
        _spin_x.step = 0.001
        _spin_x.value = value.x
        _spin_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_x)

        _spin_y = SpinBox.new()
        _spin_y.prefix = "y"
        _spin_y.min_value = -9999999999
        _spin_y.max_value = 9999999999
        _spin_y.step = 0.001
        _spin_y.value = value.y
        _spin_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_y)

        _spin_z = SpinBox.new()
        _spin_z.prefix = "z"
        _spin_z.min_value = -9999999999
        _spin_z.max_value = 9999999999
        _spin_z.step = 0.001
        _spin_z.value = value.z
        _spin_z.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_z)

        _spin_w = SpinBox.new()
        _spin_w.prefix = "w"
        _spin_w.min_value = -9999999999
        _spin_w.max_value = 9999999999
        _spin_w.step = 0.001
        _spin_w.value = value.w
        _spin_w.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_w)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return Quaternion(_spin_x.value, _spin_y.value, _spin_z.value, _spin_w.value)

class AABBEditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_x:SpinBox
    var _spin_y:SpinBox
    var _spin_z:SpinBox
    var _spin_w:SpinBox
    var _spin_h:SpinBox
    var _spin_d:SpinBox

    func _init(value:Variant) -> void:
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_x = SpinBox.new()
        _spin_x.prefix = "x"
        _spin_x.min_value = -9999999999
        _spin_x.max_value = 9999999999
        _spin_x.step = 0.001
        _spin_x.value = value.position.x
        _spin_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_x)

        _spin_y = SpinBox.new()
        _spin_y.prefix = "y"
        _spin_y.min_value = -9999999999
        _spin_y.max_value = 9999999999
        _spin_y.step = 0.001
        _spin_y.value = value.position.y
        _spin_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_y)

        _spin_z = SpinBox.new()
        _spin_z.prefix = "z"
        _spin_z.min_value = -9999999999
        _spin_z.max_value = 9999999999
        _spin_z.step = 0.001
        _spin_z.value = value.position.z
        _spin_z.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_z)

        _spin_w = SpinBox.new()
        _spin_w.prefix = "w"
        _spin_w.min_value = -9999999999
        _spin_w.max_value = 9999999999
        _spin_w.step = 0.001
        _spin_w.value = value.size.x
        _spin_w.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_w)

        _spin_h = SpinBox.new()
        _spin_h.prefix = "h"
        _spin_h.min_value = -9999999999
        _spin_h.max_value = 9999999999
        _spin_h.step = 0.001
        _spin_h.value = value.size.y
        _spin_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_h)

        _spin_d = SpinBox.new()
        _spin_d.prefix = "d"
        _spin_d.min_value = -9999999999
        _spin_d.max_value = 9999999999
        _spin_d.step = 0.001
        _spin_d.value = value.size.z
        _spin_d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_d)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return AABB(Vector3(_spin_x.value, _spin_y.value, _spin_z.value), Vector3(_spin_w.value, _spin_h.value, _spin_d.value))

class BasisEditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_xx:SpinBox
    var _spin_xy:SpinBox
    var _spin_xz:SpinBox
    var _spin_yx:SpinBox
    var _spin_yy:SpinBox
    var _spin_yz:SpinBox
    var _spin_zx:SpinBox
    var _spin_zy:SpinBox
    var _spin_zz:SpinBox

    func _init(value:Variant) -> void:
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_xx = SpinBox.new()
        _spin_xx.prefix = "xx"
        _spin_xx.min_value = -9999999999
        _spin_xx.max_value = 9999999999
        _spin_xx.step = 0.001
        _spin_xx.value = value.x.x
        _spin_xx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xx)

        _spin_xy = SpinBox.new()
        _spin_xy.prefix = "xy"
        _spin_xy.min_value = -9999999999
        _spin_xy.max_value = 9999999999
        _spin_xy.step = 0.001
        _spin_xy.value = value.x.y
        _spin_xy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xy)

        _spin_xz = SpinBox.new()
        _spin_xz.prefix = "xz"
        _spin_xz.min_value = -9999999999
        _spin_xz.max_value = 9999999999
        _spin_xz.step = 0.001
        _spin_xz.value = value.x.z
        _spin_xz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xz)

        _spin_yx = SpinBox.new()
        _spin_yx.prefix = "yx"
        _spin_yx.min_value = -9999999999
        _spin_yx.max_value = 9999999999
        _spin_yx.step = 0.001
        _spin_yx.value = value.y.x
        _spin_yx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yx)

        _spin_yy = SpinBox.new()
        _spin_yy.prefix = "yy"
        _spin_yy.min_value = -9999999999
        _spin_yy.max_value = 9999999999
        _spin_yy.step = 0.001
        _spin_yy.value = value.y.y
        _spin_yy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yy)

        _spin_yz = SpinBox.new()
        _spin_yz.prefix = "yz"
        _spin_yz.min_value = -9999999999
        _spin_yz.max_value = 9999999999
        _spin_yz.step = 0.001
        _spin_yz.value = value.y.z
        _spin_yz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yz)

        _spin_zx = SpinBox.new()
        _spin_zx.prefix = "zx"
        _spin_zx.min_value = -9999999999
        _spin_zx.max_value = 9999999999
        _spin_zx.step = 0.001
        _spin_zx.value = value.z.x
        _spin_zx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zx)

        _spin_zy = SpinBox.new()
        _spin_zy.prefix = "zy"
        _spin_zy.min_value = -9999999999
        _spin_zy.max_value = 9999999999
        _spin_zy.step = 0.001
        _spin_zy.value = value.z.y
        _spin_zy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zy)

        _spin_zz = SpinBox.new()
        _spin_zz.prefix = "zz"
        _spin_zz.min_value = -9999999999
        _spin_zz.max_value = 9999999999
        _spin_zz.step = 0.001
        _spin_zz.value = value.z.z
        _spin_zz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zz)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return Basis(
            Vector3(_spin_xx.value, _spin_xy.value, _spin_xz.value),
            Vector3(_spin_yx.value, _spin_yy.value, _spin_yz.value),
            Vector3(_spin_zx.value, _spin_zy.value, _spin_zz.value)
        )

class Transform3DEditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_xx:SpinBox
    var _spin_xy:SpinBox
    var _spin_xz:SpinBox
    var _spin_xo:SpinBox
    var _spin_yx:SpinBox
    var _spin_yy:SpinBox
    var _spin_yz:SpinBox
    var _spin_yo:SpinBox
    var _spin_zx:SpinBox
    var _spin_zy:SpinBox
    var _spin_zz:SpinBox
    var _spin_zo:SpinBox

    func _init(value:Variant) -> void:
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_xx = SpinBox.new()
        _spin_xx.prefix = "xx"
        _spin_xx.min_value = -9999999999
        _spin_xx.max_value = 9999999999
        _spin_xx.step = 0.001
        _spin_xx.value = value.basis.x.x
        _spin_xx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xx)

        _spin_xy = SpinBox.new()
        _spin_xy.prefix = "xy"
        _spin_xy.min_value = -9999999999
        _spin_xy.max_value = 9999999999
        _spin_xy.step = 0.001
        _spin_xy.value = value.basis.x.y
        _spin_xy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xy)

        _spin_xz = SpinBox.new()
        _spin_xz.prefix = "xz"
        _spin_xz.min_value = -9999999999
        _spin_xz.max_value = 9999999999
        _spin_xz.step = 0.001
        _spin_xz.value = value.basis.x.z
        _spin_xz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xz)

        _spin_xo = SpinBox.new()
        _spin_xo.prefix = "xo"
        _spin_xo.min_value = -9999999999
        _spin_xo.max_value = 9999999999
        _spin_xo.step = 0.001
        _spin_xo.value = value.origin.x
        _spin_xo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xo)

        _spin_yx = SpinBox.new()
        _spin_yx.prefix = "yx"
        _spin_yx.min_value = -9999999999
        _spin_yx.max_value = 9999999999
        _spin_yx.step = 0.001
        _spin_yx.value = value.basis.y.x
        _spin_yx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yx)

        _spin_yy = SpinBox.new()
        _spin_yy.prefix = "yy"
        _spin_yy.min_value = -9999999999
        _spin_yy.max_value = 9999999999
        _spin_yy.step = 0.001
        _spin_yy.value = value.basis.y.y
        _spin_yy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yy)

        _spin_yz = SpinBox.new()
        _spin_yz.prefix = "yz"
        _spin_yz.min_value = -9999999999
        _spin_yz.max_value = 9999999999
        _spin_yz.step = 0.001
        _spin_yz.value = value.basis.y.z
        _spin_yz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yz)

        _spin_yo = SpinBox.new()
        _spin_yo.prefix = "yo"
        _spin_yo.min_value = -9999999999
        _spin_yo.max_value = 9999999999
        _spin_yo.step = 0.001
        _spin_yo.value = value.origin.y
        _spin_yo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yo)

        _spin_zx = SpinBox.new()
        _spin_zx.prefix = "zx"
        _spin_zx.min_value = -9999999999
        _spin_zx.max_value = 9999999999
        _spin_zx.step = 0.001
        _spin_zx.value = value.basis.z.x
        _spin_zx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zx)

        _spin_zy = SpinBox.new()
        _spin_zy.prefix = "zy"
        _spin_zy.min_value = -9999999999
        _spin_zy.max_value = 9999999999
        _spin_zy.step = 0.001
        _spin_zy.value = value.basis.z.y
        _spin_zy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zy)

        _spin_zz = SpinBox.new()
        _spin_zz.prefix = "zz"
        _spin_zz.min_value = -9999999999
        _spin_zz.max_value = 9999999999
        _spin_zz.step = 0.001
        _spin_zz.value = value.basis.z.z
        _spin_zz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zz)

        _spin_zo = SpinBox.new()
        _spin_zo.prefix = "zo"
        _spin_zo.min_value = -9999999999
        _spin_zo.max_value = 9999999999
        _spin_zo.step = 0.001
        _spin_zo.value = value.origin.z
        _spin_zo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zo)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return Transform3D(
            Vector3(_spin_xx.value, _spin_xy.value, _spin_xz.value),
            Vector3(_spin_yx.value, _spin_yy.value, _spin_yz.value),
            Vector3(_spin_zx.value, _spin_zy.value, _spin_zz.value),
            Vector3(_spin_xo.value, _spin_yo.value, _spin_zo.value)
        )

class ProjectionEditionControl extends EditionControl:

    var _vbox:VBoxContainer
    var _spin_xx:SpinBox
    var _spin_xy:SpinBox
    var _spin_xz:SpinBox
    var _spin_xw:SpinBox
    var _spin_yx:SpinBox
    var _spin_yy:SpinBox
    var _spin_yz:SpinBox
    var _spin_yw:SpinBox
    var _spin_zx:SpinBox
    var _spin_zy:SpinBox
    var _spin_zz:SpinBox
    var _spin_zw:SpinBox
    var _spin_wx:SpinBox
    var _spin_wy:SpinBox
    var _spin_wz:SpinBox
    var _spin_ww:SpinBox

    func _init(value:Variant) -> void:
        _vbox = VBoxContainer.new()
        _vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _spin_xx = SpinBox.new()
        _spin_xx.prefix = "xx"
        _spin_xx.min_value = -9999999999
        _spin_xx.max_value = 9999999999
        _spin_xx.step = 0.001
        _spin_xx.value = value.x.x
        _spin_xx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xx)

        _spin_xy = SpinBox.new()
        _spin_xy.prefix = "xy"
        _spin_xy.min_value = -9999999999
        _spin_xy.max_value = 9999999999
        _spin_xy.step = 0.001
        _spin_xy.value = value.x.y
        _spin_xy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xy)

        _spin_xz = SpinBox.new()
        _spin_xz.prefix = "xz"
        _spin_xz.min_value = -9999999999
        _spin_xz.max_value = 9999999999
        _spin_xz.step = 0.001
        _spin_xz.value = value.x.z
        _spin_xz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xz)

        _spin_xw = SpinBox.new()
        _spin_xw.prefix = "xw"
        _spin_xw.min_value = -9999999999
        _spin_xw.max_value = 9999999999
        _spin_xw.step = 0.001
        _spin_xw.value = value.x.w
        _spin_xw.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_xw)

        _spin_yx = SpinBox.new()
        _spin_yx.prefix = "yx"
        _spin_yx.min_value = -9999999999
        _spin_yx.max_value = 9999999999
        _spin_yx.step = 0.001
        _spin_yx.value = value.y.x
        _spin_yx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yx)

        _spin_yy = SpinBox.new()
        _spin_yy.prefix = "yy"
        _spin_yy.min_value = -9999999999
        _spin_yy.max_value = 9999999999
        _spin_yy.step = 0.001
        _spin_yy.value = value.y.y
        _spin_yy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yy)

        _spin_yz = SpinBox.new()
        _spin_yz.prefix = "yz"
        _spin_yz.min_value = -9999999999
        _spin_yz.max_value = 9999999999
        _spin_yz.step = 0.001
        _spin_yz.value = value.y.z
        _spin_yz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yz)

        _spin_yw = SpinBox.new()
        _spin_yw.prefix = "yw"
        _spin_yw.min_value = -9999999999
        _spin_yw.max_value = 9999999999
        _spin_yw.step = 0.001
        _spin_yw.value = value.y.w
        _spin_yw.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_yw)

        _spin_zx = SpinBox.new()
        _spin_zx.prefix = "zx"
        _spin_zx.min_value = -9999999999
        _spin_zx.max_value = 9999999999
        _spin_zx.step = 0.001
        _spin_zx.value = value.z.x
        _spin_zx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zx)

        _spin_zy = SpinBox.new()
        _spin_zy.prefix = "zy"
        _spin_zy.min_value = -9999999999
        _spin_zy.max_value = 9999999999
        _spin_zy.step = 0.001
        _spin_zy.value = value.z.y
        _spin_zy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zy)

        _spin_zz = SpinBox.new()
        _spin_zz.prefix = "zz"
        _spin_zz.min_value = -9999999999
        _spin_zz.max_value = 9999999999
        _spin_zz.step = 0.001
        _spin_zz.value = value.z.z
        _spin_zz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zz)

        _spin_zw = SpinBox.new()
        _spin_zw.prefix = "zw"
        _spin_zw.min_value = -9999999999
        _spin_zw.max_value = 9999999999
        _spin_zw.step = 0.001
        _spin_zw.value = value.z.w
        _spin_zw.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_zw)

        _spin_wx = SpinBox.new()
        _spin_wx.prefix = "wx"
        _spin_wx.min_value = -9999999999
        _spin_wx.max_value = 9999999999
        _spin_wx.step = 0.001
        _spin_wx.value = value.w.x
        _spin_wx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_wx)

        _spin_wy = SpinBox.new()
        _spin_wy.prefix = "wy"
        _spin_wy.min_value = -9999999999
        _spin_wy.max_value = 9999999999
        _spin_wy.step = 0.001
        _spin_wy.value = value.w.y
        _spin_wy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_wy)

        _spin_wz = SpinBox.new()
        _spin_wz.prefix = "wz"
        _spin_wz.min_value = -9999999999
        _spin_wz.max_value = 9999999999
        _spin_wz.step = 0.001
        _spin_wz.value = value.w.z
        _spin_wz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_wz)

        _spin_ww = SpinBox.new()
        _spin_ww.prefix = "ww"
        _spin_ww.min_value = -9999999999
        _spin_ww.max_value = 9999999999
        _spin_ww.step = 0.001
        _spin_ww.value = value.w.w
        _spin_ww.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _vbox.add_child(_spin_ww)

    func get_control() -> Control:
        return _vbox

    func get_value() -> Variant:
        return Projection(
            Vector4(_spin_xx.value, _spin_xy.value, _spin_xz.value, _spin_xw.value),
            Vector4(_spin_yx.value, _spin_yy.value, _spin_yz.value, _spin_yw.value),
            Vector4(_spin_zx.value, _spin_zy.value, _spin_zz.value, _spin_zw.value),
            Vector4(_spin_wx.value, _spin_wy.value, _spin_wz.value, _spin_ww.value)
        )

class ColorEditionControl extends EditionControl:

    var _picker:ColorPicker

    func _init(value:Variant) -> void:
        _picker = ColorPicker.new()
        _picker.color = value
        _picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    func get_control() -> Control:
        return _picker

    func get_value() -> Variant:
        return _picker.color

func _on_close_requested() -> void:
    _on_cancel_button_pressed()

func _on_validate_button_pressed() -> void:
    on_close.emit(true, _edition_control.get_value())
    hide()
    call_deferred("queue_free")

func _on_cancel_button_pressed() -> void:
    on_close.emit(false, null)
    hide()
    call_deferred("queue_free")
