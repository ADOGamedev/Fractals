extends Control

@onready var single_color_selector := preload("res://scenes/single_color_gradient_selector.tscn")
var COLOR_SELECTOR_SIZE = Vector2(11, 25)
var grad : Gradient


func _process(_delta: float) -> void:	
	update_gradient_based_on_selectors()

	if Input.is_key_pressed(KEY_F2):
		var time = Time.get_unix_time_from_system()
		var path = "res://assets/gradients/gradient_%d.tres" % time

		ResourceSaver.save(grad, path)


func update_gradient_based_on_selectors() -> void:
	grad = Gradient.new()

	var first_child_i = -1
	var last_child_i = 0
	var min_offset = 1.0
	var max_offset = 0.0

	var can_queue_free = can_selectors_queue_free()

	for child_i in range(get_child_count()):
		var child = get_child(child_i)
		if !child.is_in_group("single_color_gradient_selector"):
			continue

		var selector_offset = child.size.x / 2.0
		var error_margin = 0.0001
		
		child.can_queue_free = can_queue_free
		child.position.x = clamp(child.position.x, -selector_offset + error_margin, %gradient_texture.size.x - selector_offset - error_margin)
		
		var offset = (child.position.x + selector_offset) / %gradient_texture.size.x

		if offset < min_offset:
			first_child_i = child_i
			min_offset = offset
		if offset > max_offset:
			last_child_i = child_i
			max_offset = offset

		offset = max(0, offset)
		grad.add_point(offset, child.get_color())

	set_correct_colors_in_the_endpoints(first_child_i, last_child_i)

	%gradient_texture.texture.gradient = grad


func can_selectors_queue_free() -> bool:
	var selectors_count = 0
	for child in get_children():
		if child.is_in_group("single_color_gradient_selector"):
			selectors_count += 1

	if selectors_count <= 2:
		return false
	
	return true


func set_correct_colors_in_the_endpoints(first_child_i: int, last_child_i: int) -> void:
	grad.remove_point(0)

	var first_child = get_child(first_child_i)
	var last_child = get_child(last_child_i)
	if first_child.has_method("get_color"):
		grad.set_color(0, first_child.get_color())
	
	if last_child.has_method("get_color"):
		grad.set_color(grad.get_point_count() - 1, last_child.get_color())


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

	for point_i in range(grad.get_point_count() - 1):
		var offset = grad.get_offset(point_i)
		add_new_single_color_selector(offset, grad.sample(offset))
