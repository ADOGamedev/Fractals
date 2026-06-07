extends Control

@onready var single_color_selector := preload("res://scenes/single_color_gradient_selector.tscn")
var COLOR_SELECTOR_SIZE = Vector2(11, 25)
var grad : Gradient

func _ready() -> void:
	pass


func _process(_delta: float) -> void:	
	var can_selectors_queue_free = true
	var selectors_count = 0
	for child in get_children():
		if child.is_in_group("single_color_gradient_selector"):
			selectors_count += 1

	if selectors_count <= 2:
		can_selectors_queue_free = false

	grad = Gradient.new()

	var first_child_i = -1
	var last_child_i = 0
	var min_offset = 1.0
	var max_offset = 0.0

	for child_i in range(get_child_count()):
		var child = get_child(child_i)
		if !child.is_in_group("single_color_gradient_selector"):
			continue
		
		child.can_queue_free = can_selectors_queue_free
		child.position.x = clamp(child.position.x, -child.size.x / 2.0, %gradient_texture.size.x - child.size.x / 2.0)
		
		var offset = (child.position.x) / %gradient_texture.size.x

		if offset < min_offset:
			first_child_i = child_i
			min_offset = offset
		if offset > max_offset:
			last_child_i = child_i
			max_offset = offset

		grad.add_point(offset, child.get_color())


	grad.set_color(0, get_child(first_child_i).get_color())
	grad.set_color(grad.get_point_count() - 1, get_child(last_child_i).get_color())

	%gradient_texture.texture.gradient = grad


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !%gradient_texture.get_global_rect().has_point(event.global_position):
			return

		var offset = event.position.x / %gradient_texture.size.x
		var color = grad.sample(offset)

		add_new_single_color_selector(offset, color)


func add_new_single_color_selector(offset: float, color: Color) -> void:
	var new_selector = single_color_selector.instantiate()
	new_selector.initial_color = color
	new_selector.size = COLOR_SELECTOR_SIZE
	new_selector.position.x = %gradient_texture.size.x * offset - new_selector.size.x / 2.0
	add_child(new_selector)


func set_gradient(gradient: Gradient) -> void:
	grad = gradient
	%gradient_texture.texture.gradient = gradient

	for child in get_children():
		if child.is_in_group("single_color_gradient_selector"):
			child.queue_free()

	for point_i in range(grad.get_point_count()):
		var offset = grad.get_offset(point_i)
		add_new_single_color_selector(offset, grad.sample(offset))
