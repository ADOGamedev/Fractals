extends VBoxContainer

@export var initial_color := Color.BLACK
var dragging := false
var can_queue_free = true

func get_color() -> Color:
	return %ColorPickerButton.color

func set_color(color: Color) -> void:
	%ColorPickerButton.color = color

func _ready() -> void:
	set_color(initial_color)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		var mouse_in = get_global_rect().has_point(event.position)
		if mouse_in and can_queue_free:
			queue_free()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_in = get_global_rect().has_point(event.position)
		
		if event.pressed:
			dragging = mouse_in
		else:
			dragging = false
	
	if event is InputEventMouseMotion and dragging:
		position.x += event.relative.x
