extends ColorRect

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



func _process(delta: float) -> void:
	Global.current_shader_material = material
	
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")

	update_shader_parameters()
	update_camera_transform(delta)


func update_shader_parameters() -> void:
	pass
	
	
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
