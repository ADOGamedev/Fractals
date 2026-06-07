extends Control

@onready var single_color_selector := preload("res://scenes/single_color_gradient_selector.tscn")
var COLOR_SELECTOR_SIZE = Vector2(7, 25)
var grad : Gradient

func _ready() -> void:
	grad = %gradient_texture.texture.gradient


func _process(_delta: float) -> void:	
	var i = 0
	for child in get_children():
		if !child.is_in_group("single_color_gradient_selector"):
			continue
		
		child.position.x = clamp(child.position.x, -child.size.x / 2.0, %gradient_texture.size.x - child.size.x / 2.0)
		var offset = (child.position.x) / %gradient_texture.size.x
		grad.set_color(i, child.get_color())
		grad.set_offset(i, offset)
		i += 1


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var offset = event.position.x / %gradient_texture.size.x
		var color = grad.sample(event.position.x)

		add_new_single_color_selector(offset, color)
		grad.add_point(offset, color)


func add_new_single_color_selector(offset: float, color: Color) -> void:
	var new_selector = single_color_selector.instantiate()
	new_selector.initial_color = color
	new_selector.size = COLOR_SELECTOR_SIZE
	new_selector.position.x = %gradient_texture.size.x * offset - new_selector.size.x / 2.0
	add_child(new_selector)


func set_gradient(gradient: Gradient) -> void:
	grad = gradient
	%gradient_texture.texture.gradient = gradient

	for point_i in range(grad.get_point_count()):
		var offset = grad.get_offset(point_i)
		add_new_single_color_selector(offset, grad.sample(offset))