extends Control

@export var LERP_VALUE = 15

@export var initial_complex_num = Vector2.ZERO
@export var variable_name = "z"

var selecting = false

var last_click_time = 0
var double_click_threshold_ms = 250


func _ready() -> void:	
	%real_part.set_variable_name("Re(%s)" % str(variable_name))
	%complex_part.set_variable_name("Im(%s)" % str(variable_name))

	%real_part.set_value(initial_complex_num.x)
	%complex_part.set_value(initial_complex_num.y)	
	%real_part.initial_value = initial_complex_num.x
	%complex_part.initial_value = initial_complex_num.y

	var ball_offset = %ball_pointer.size * %ball_pointer.scale / 2.0
	%ball_pointer.global_position = shader_coords_to_global_coords(initial_complex_num) - ball_offset


func _process(_delta: float) -> void:
	queue_redraw()

	%ball_pointer.scale = Vector2(2.0, 2.0) / %Camera2D.zoom
	var ball_offset = %ball_pointer.size * %ball_pointer.scale / 2.0

	if %disabled.visible:
		return

	if selecting:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

		var shader_coords = global_coords_to_shader_coords(%ball_pointer.global_position + ball_offset)
		%real_part.set_value(shader_coords.x)
		%complex_part.set_value(shader_coords.y)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		var shader_coords = Vector2(%real_part.get_value(), %complex_part.get_value())
		%ball_pointer.global_position = shader_coords_to_global_coords(shader_coords) - ball_offset



func _input(event: InputEvent) -> void: 
	if %disabled.visible:
		return

	var mouse_pos = %SubViewportContainer.get_local_mouse_position()
	var mouse_in = %SubViewportContainer.get_global_rect().has_point(get_viewport().get_mouse_position())

	if !mouse_in:
		selecting = false
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !event.pressed:
			return
			 
		if (Time.get_ticks_msec() - last_click_time) < double_click_threshold_ms:
			%real_part.set_value(initial_complex_num.x)
			%complex_part.set_value(initial_complex_num.y)

		last_click_time = Time.get_ticks_msec()


	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		selecting = event.pressed
	
	if selecting:
		var viewport_size = %SubViewportContainer.size
		var world_pos = %Camera2D.global_position + (mouse_pos - viewport_size / 2.0) / %Camera2D.zoom

		var ball_offset = %ball_pointer.size * %ball_pointer.scale / 2.0
		%ball_pointer.global_position = world_pos - ball_offset


func global_coords_to_shader_coords(coord: Vector2) -> Vector2:
	var fractal_offset = %fractal.material.get_shader_parameter("offset")
	var fractal_scale = %fractal.material.get_shader_parameter("scale")
	var center = %fractal.global_position + %fractal.size / 2.0

	return (coord - center) / fractal_scale / %fractal.size - fractal_offset


func shader_coords_to_global_coords(coord: Vector2) -> Vector2:
	var fractal_offset = %fractal.material.get_shader_parameter("offset")
	var fractal_scale = %fractal.material.get_shader_parameter("scale")
	var center = %fractal.global_position + %fractal.size / 2.0

	return (fractal_offset + coord) * %fractal.size * fractal_scale + center

func get_complex_num() -> Vector2:
	return Vector2(%real_part.get_value(), %complex_part.get_value())

func set_target_complex_num(val: Vector2) -> void:
	%real_part.set_value(val.x)
	%complex_part.set_value(val.y)

func set_initial_complex_num(val: Vector2) -> void:
	initial_complex_num = val
	%real_part.initial_value = val.x
	%complex_part.initial_value = val.y

func set_disabled(disabled: bool) -> void:
	%disabled.visible = disabled

func set_shader_parameter(parameter: String, value) -> void:
	%fractal.material.set_shader_parameter(parameter, value)
