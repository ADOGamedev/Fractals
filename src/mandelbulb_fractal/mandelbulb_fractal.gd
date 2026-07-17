extends ColorRect

var MANDELBOX_INDEX = 2

var MANDELBULB_DEFAULT_C = Vector3(0, -1, 0)
var MANDELBOX_DEFAULT_C = Vector3(0, 8.9, 0)

var MOVE_SPEED_FACTOR = 1.05
@export var camera_move_speed = 3
@export var sensitivity = 0.003

var DEFAULT_CAMERA_POSITION = Vector3(0, 0, -3)
var DEFAULT_CAMERA_SPEED = 3
var DEFAULT_CAMERA_YAW = 0
var DEFAULT_CAMERA_PITCH = 0

var camera_position = DEFAULT_CAMERA_POSITION
var camera_yaw = 0
var camera_pitch = 0

var dragging = false

@onready var ray_march_iterations = %ray_march_iterations
@onready var iterations = %iterations
@onready var exp = %exp
@onready var exponent = %exponent
@onready var lower_bound = %lower_bound
@onready var fractals_option_button = %fractals_option_button
@onready var julia_checkbox = %julia_checkbox

@onready var z = %z
@onready var constant = %constant

@onready var mandelbox_s = %mandelbox_s
@onready var mandelbox_r = %mandelbox_r
@onready var mandelbox_or = %mandelbox_or
@onready var mandelbox_f = %mandelbox_f
@onready var mandelbox_parameters = %mandelbox_parameters

@onready var mandelbulb_color_widget = %MandelbulbColorWidget

var gradient_tex := GradientTexture2D.new()

var last_mandelbox = null
var last_julia = null


func _ready() -> void:
	mandelbulb_color_widget.set_gradient_repetition_target_value(ray_march_iterations.get_value())

	constant.set_initial_complex_num(MANDELBULB_DEFAULT_C)
	constant.set_target_complex_num(MANDELBULB_DEFAULT_C)
	

func _process(delta: float) -> void:
	Global.current_shader_material = material
	
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")

	update_shader_parameters()
	update_camera_transform(delta)

	mandelbulb_color_widget.set_gradient_repetition_initial_value(ray_march_iterations.get_value())


func update_shader_parameters() -> void:
	material.set_shader_parameter("hit_pos_strength", MandelbulbConfig.hit_position_strength)
	material.set_shader_parameter("iteratios_coloring_strength", MandelbulbConfig.iteratios_coloring_strength)
	material.set_shader_parameter("lighting_strength", MandelbulbConfig.lighting_strength)
	material.set_shader_parameter("ambient_light", MandelbulbConfig.ambient_light)
	material.set_shader_parameter("gradient_repetition", MandelbulbConfig.gradient_repetition)
	material.set_shader_parameter("gradient_attenuation", MandelbulbConfig.gradient_attenuation)
	material.set_shader_parameter("gradient_offset", MandelbulbConfig.gradient_offset)
	material.set_shader_parameter("single_color_bg", MandelbulbConfig.single_color_bg)
	material.set_shader_parameter("bg_color", MandelbulbConfig.bg_color)

	var grad_tex = GradientTexture2D.new()
	grad_tex.gradient = MandelbulbConfig.gradient
	material.set_shader_parameter("gradient", grad_tex)

	var julia = julia_checkbox.button_pressed
	material.set_shader_parameter("ray_march_iterations", ray_march_iterations.get_value())
	material.set_shader_parameter("iterations", iterations.get_value())
	material.set_shader_parameter("julia", julia)
	material.set_shader_parameter("exponent", exp.get_value())

	z.set_disabled(julia)
	constant.set_disabled(!julia)
	z.get_node("InOutWidget").set_button_disabled(julia)
	constant.get_node("InOutWidget").set_button_disabled(!julia)
	
	material.set_shader_parameter("lower_bound", lower_bound.get_value())

	material.set_shader_parameter("initial_z", z.get_complex_num())
	material.set_shader_parameter("constant_c", constant.get_complex_num())

	material.set_shader_parameter("mandelbox_s", mandelbox_s.get_value())
	material.set_shader_parameter("mandelbox_r", mandelbox_r.get_value())
	material.set_shader_parameter("mandelbox_or", mandelbox_or.get_value())
	material.set_shader_parameter("mandelbox_f", mandelbox_f.get_value())

	var mandelbox = fractals_option_button.selected == MANDELBOX_INDEX
	material.set_shader_parameter("mandelbox", mandelbox)

	exp.set_disabled(mandelbox)
	exponent.get_node("InOutWidget").set_button_disabled(mandelbox)

	mandelbox_s.set_disabled(!mandelbox)
	mandelbox_r.set_disabled(!mandelbox)
	mandelbox_or.set_disabled(!mandelbox)
	mandelbox_f.set_disabled(!mandelbox)
	mandelbox_parameters.get_node("InOutWidget").set_button_disabled(!mandelbox)
	


func update_camera_transform(delta: float) -> void:
	var cp = cos(camera_pitch)
	var sp = sin(camera_pitch)
	var cy = cos(camera_yaw)
	var sy = sin(camera_yaw)

	var camera_direction := Vector3(
		cp * sy,
		sp,
		cp * cy
	)

	var world_up := Vector3.UP

	var camera_right := camera_direction.cross(world_up)
	if camera_right.length_squared() > 0.0:
		camera_right = camera_right.normalized()

	var camera_up := camera_right.cross(camera_direction)
	if camera_up.length_squared() > 0.0:
		camera_up = camera_up.normalized()

	camera_position += get_input_direction(camera_direction, camera_right) * camera_move_speed * delta

	material.set_shader_parameter("camPos", camera_position)
	material.set_shader_parameter("camDir", camera_direction)
	material.set_shader_parameter("camRight", camera_right)
	material.set_shader_parameter("camUp", camera_up)


func get_input_direction(cam_dir: Vector3, cam_right: Vector3) -> Vector3:
	var dir := Vector3.ZERO

	if Input.is_action_pressed("left"):
		dir -= cam_right
	if Input.is_action_pressed("right"):
		dir += cam_right

	if Input.is_action_pressed("forward"):
		dir += cam_dir
	if Input.is_action_pressed("backward"):
		dir -= cam_dir

	if Input.is_action_pressed("up"):
		dir += Vector3.UP
	if Input.is_action_pressed("down"):
		dir += Vector3.DOWN

	return dir.normalized()


func reset_camera() -> void:
	camera_move_speed = DEFAULT_CAMERA_SPEED

	var tween := create_tween().set_parallel(true)

	tween.tween_property(self, "camera_position", DEFAULT_CAMERA_POSITION, 0.15)
	tween.tween_property(self, "camera_yaw", DEFAULT_CAMERA_YAW, 0.15)
	tween.tween_property(self, "camera_pitch", DEFAULT_CAMERA_PITCH, 0.15)

	tween.finished.connect(func():
		camera_position = DEFAULT_CAMERA_POSITION
		camera_yaw = DEFAULT_CAMERA_YAW
		camera_pitch = DEFAULT_CAMERA_PITCH
	)



func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			dragging = event.pressed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_move_speed /= MOVE_SPEED_FACTOR
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_move_speed *= MOVE_SPEED_FACTOR
	
	if event is InputEventMouseMotion and dragging:
		camera_yaw -= event.relative.x * sensitivity
		camera_pitch -= event.relative.y * sensitivity

		camera_pitch = clamp(camera_pitch, deg_to_rad(-89), deg_to_rad(89))


func _on_utilities_panel_restart_camera() -> void:
	reset_camera()


func _on_fractals_option_button_item_selected(index: int) -> void:
	if index == MANDELBOX_INDEX:
		constant.set_initial_complex_num(MANDELBOX_DEFAULT_C)
		constant.set_target_complex_num(MANDELBOX_DEFAULT_C)
	else:
		constant.set_initial_complex_num(MANDELBULB_DEFAULT_C)
		constant.set_target_complex_num(MANDELBULB_DEFAULT_C)
