extends Button

enum Direction {LEFT, UP, DOWN, RIGHT}


@export var direction : Direction = Direction.RIGHT
@export var radius = 20
@export var displacement := Vector2(-363.0, 0.0)
@export var TWEEN_TIME = 0.15

var parent_hidden = true

func _ready() -> void:
	if get_parent():
		get_parent().position += displacement

	for state in ["normal", "hover", "pressed", "disabled"]:
		var style = get_theme_stylebox(state).duplicate()

		if direction == Direction.RIGHT or direction == Direction.UP:
			style.corner_radius_top_right = radius
		if direction == Direction.RIGHT or direction == Direction.DOWN:
			style.corner_radius_bottom_right = radius
		if direction == Direction.LEFT or direction == Direction.UP:
			style.corner_radius_top_left = radius
		if direction == Direction.LEFT or direction == Direction.DOWN:
			style.corner_radius_bottom_left = radius

		add_theme_stylebox_override(state, style)


func move_parent(amount: Vector2) -> void:
	if !get_parent():
		return
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(get_parent(), "position", get_parent().position + amount, TWEEN_TIME)


func set_button_disabled(d: bool) -> void:
	if !parent_hidden and d:
		parent_hidden = true
		move_parent(displacement)
	
	disabled = d


func _on_pressed() -> void:
	parent_hidden = !parent_hidden
	move_parent(displacement if parent_hidden else -displacement)
