extends ColorRect

var MOVE_SPEED_FACTOR = 1.05
@export var camera_move_speed = 3
@export var sensitivity = 0.003

var DEFAULT_CAMERA_POSITION = Vector3(0, 0, -3)
var DEFAULT_CAMERA_YAW = 0
var DEFAULT_CAMERA_PITCH = 0

var camera_position = DEFAULT_CAMERA_POSITION
var camera_yaw = 0
var camera_pitch = 0

var dragging = false

func _ready() -> void:
	%MandelbulbColorWidget.set_gradient_repetition_target_value(%ray_march_iterations.get_value())

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")

	update_shader_parameters()
	update_camera_transform(delta)

	%MandelbulbColorWidget.set_gradient_repetition_initial_value(%ray_march_iterations.get_value())


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

	var julia = %julia_checkbox.button_pressed
	material.set_shader_parameter("ray_march_iterations", %ray_march_iterations.get_value())
	material.set_shader_parameter("iterations", %iterations.get_value())
	material.set_shader_parameter("julia", julia)
	material.set_shader_parameter("exponent", %exp.get_value())
	
	material.set_shader_parameter("lower_bound", %lower_bound.get_value())
		
	%z.set_disabled(julia)
	%constant.set_disabled(!julia)
	%z.get_node("InOutWidget").set_button_disabled(julia)
	%constant.get_node("InOutWidget").set_button_disabled(!julia)

	material.set_shader_parameter("initial_z", %z.get_complex_num())
	material.set_shader_parameter("constant_c", %constant.get_complex_num())


func update_camera_transform(delta: float) -> void:
	var camera_direction = Vector3(
		cos(camera_pitch) * sin(camera_yaw),
		sin(camera_pitch),
		cos(camera_pitch) * cos(camera_yaw)
	).normalized()

	camera_position += get_input_direction(camera_direction) * camera_move_speed * delta

	material.set_shader_parameter("camPos", camera_position)
	material.set_shader_parameter("camDir", camera_direction)

func reset_camera() -> void:
	var tween = get_tree().create_tween().set_parallel(true)
	var camera_direction = Vector3(
		cos(DEFAULT_CAMERA_PITCH) * sin(DEFAULT_CAMERA_YAW),
		sin(DEFAULT_CAMERA_PITCH),
		cos(DEFAULT_CAMERA_PITCH) * cos(DEFAULT_CAMERA_YAW)
	).normalized()

	tween.tween_property(self, "material:shader_parameter/camPos", DEFAULT_CAMERA_POSITION, 0.15)
	tween.tween_property(self, "material:shader_parameter/camDir", camera_direction, 0.15)

	await tween.finished

	camera_position = DEFAULT_CAMERA_POSITION
	camera_yaw = DEFAULT_CAMERA_YAW
	camera_pitch = DEFAULT_CAMERA_PITCH


func get_input_direction(cam_dir: Vector3) -> Vector3:
	var world_up = Vector3.UP
	var camera_right = cam_dir.cross(world_up).normalized()

	var dir := Vector3.ZERO
	if Input.is_action_pressed("left"):
		dir -= camera_right
	if Input.is_action_pressed("right"):
		dir += camera_right

	if Input.is_action_pressed("up"):
		dir += Vector3.UP
	if Input.is_action_pressed("down"):
		dir += Vector3.DOWN

	if Input.is_action_pressed("forward"):
		dir += cam_dir
	if Input.is_action_pressed("backward"):
		dir -= cam_dir

	return dir.normalized()


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