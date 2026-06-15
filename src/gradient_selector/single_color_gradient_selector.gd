extends Control

@export var initial_color := Color.BLACK
var dragging := false

var drag_start_pos : Vector2
var drag_end_pos : Vector2

var can_queue_free = true

func get_color() -> Color:
	return %ColorPickerButton.color

func set_color(color: Color) -> void:
	%ColorPickerButton.color = color

func _ready() -> void:
	set_color(initial_color)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if can_queue_free:
			queue_free()

	if dragging and drag_start_pos != drag_end_pos:
		%ColorPickerButton.mouse_filter = MOUSE_FILTER_IGNORE
	else:
		%ColorPickerButton.mouse_filter = MOUSE_FILTER_PASS


	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start_pos = event.position
		else:
			dragging = false

	
	if event is InputEventMouseMotion and dragging:
		position.x += event.relative.x
		drag_end_pos = event.position
