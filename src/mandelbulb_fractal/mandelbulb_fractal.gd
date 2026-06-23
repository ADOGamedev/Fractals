extends ColorRect

var MOVE_SPEED_FACTOR = 1.05
@export var camera_move_speed = 3
@export var sensitivity = 0.003

var camera_position = Vector3(0, 0, -3)
var camera_yaw = 0
var camera_pitch = 0

var dragging = false


func _process(delta: float) -> void:
	update_shader_parameters()
	update_camera_transform(delta)


func update_shader_parameters() -> void:
	material.set_shader_parameter("ray_march_iterations", %ray_march_iterations.get_value())
	material.set_shader_parameter("iterations", %iterations.get_value())
	material.set_shader_parameter("julia", %julia_checkbox.button_pressed)


func update_camera_transform(delta: float) -> void:
	var camera_direction = Vector3(
		cos(camera_pitch) * sin(camera_yaw),
		sin(camera_pitch),
		cos(camera_pitch) * cos(camera_yaw)
	).normalized()

	camera_position += get_input_direction(camera_direction) * camera_move_speed * delta

	material.set_shader_parameter("camPos", camera_position)
	material.set_shader_parameter("camDir", camera_direction)


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