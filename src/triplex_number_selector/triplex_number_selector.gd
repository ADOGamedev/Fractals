extends Control

@export var initial_complex_num = Vector3.ZERO
@export var variable_name = "z"


func _ready() -> void:
	%real_part.set_variable_name(variable_name + "ᵣ")
	%i_part.set_variable_name(variable_name + "ᵢ")
	%j_part.set_variable_name(variable_name + "ⱼ")

	%real_part.set_value(initial_complex_num.x)
	%i_part.set_value(initial_complex_num.y)
	%j_part.set_value(initial_complex_num.z)
	%real_part.initial_value = initial_complex_num.x
	%i_part.initial_value = initial_complex_num.y
	%j_part.initial_value = initial_complex_num.z


func get_complex_num() -> Vector3:
	return Vector3(%real_part.get_value(), %i_part.get_value(), %j_part.get_value())

func set_target_complex_num(val: Vector3) -> void:
	%real_part.set_value(val.x)
	%i_part.set_value(val.y)
	%j_part.set_value(val.z)

func set_initial_complex_num(val: Vector3) -> void:
	initial_complex_num = val
	%real_part.initial_value = val.x
	%i_part.initial_value = val.y
	%j_part.initial_value = val.z

func set_disabled(disabled: bool) -> void:
	%disabled.visible = disabled
