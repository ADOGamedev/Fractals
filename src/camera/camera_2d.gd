extends Camera2D

@export var MIN_ZOOM = Vector2(1.0, 1.0)
@export var drag_speed := 1.0
@export var zoom_multiplier := 1.05

enum Direction {LEFT, UP, RIGHT, DOWN}
var limits = [-640, -360, 1920, 1080]

var dragging := false
var last_mouse_pos := Vector2.ZERO


func _ready() -> void:
	position = get_viewport_rect().size / 2.0


func _process(_delta: float) -> void:
	if zoom < MIN_ZOOM:
		zoom = MIN_ZOOM
		clamp_position()
		
	if dragging:
		var mouse_pos := get_viewport().get_mouse_position()
		var delta := mouse_pos - last_mouse_pos

		position -= delta * drag_speed * (1.0 / zoom.x)
		last_mouse_pos = mouse_pos

		clamp_position()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse_pos = event.position

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom /= zoom_multiplier
			clamp_position()

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= zoom_multiplier
			clamp_position()


func clamp_position() -> void:
	var size = get_viewport_rect().size
	var half = size / 2.0 / zoom
	position.x = clamp(position.x, limits[Direction.LEFT] + half.x, limits[Direction.RIGHT] - half.x)
	position.y = clamp(position.y, limits[Direction.UP] + half.y, limits[Direction.DOWN] - half.y)