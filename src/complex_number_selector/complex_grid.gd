extends Control

@export var font : Font
@export var main_lines_weight = 2
@export var ticks_height = 6


@export var fractal : ColorRect
@export var camera : Camera2D


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if !fractal or !camera:
		return

	var origin = fractal_pos_to_screen_pos(Vector2.ZERO)

	draw_line(Vector2(-fractal.size.x, origin.y), Vector2(fractal.size.x, origin.y), Color.WHITE, (main_lines_weight + 2) / camera.zoom.y)
	draw_line(Vector2(-fractal.size.x, origin.y), Vector2(fractal.size.x, origin.y), Color.BLACK, main_lines_weight / camera.zoom.y)
	
	draw_line(Vector2(origin.x, -fractal.size.y), Vector2(origin.x, fractal.size.y), Color.WHITE, (main_lines_weight + 2) / camera.zoom.x)
	draw_line(Vector2(origin.x, -fractal.size.y), Vector2(origin.x, fractal.size.y), Color.BLACK, main_lines_weight / camera.zoom.x)

	for i in range(-5, 6):
		var weight_mult = 1.0 if (i % 2 == 0) else 0.5
		draw_marker(Vector2(i/2., 0), weight_mult)
		draw_marker(Vector2(0, i/2.), weight_mult)


func draw_marker(p: Vector2, height_multiplier = 1.0) -> void:
	var s = fractal_pos_to_screen_pos(p)
	if p == Vector2.ZERO:
		return

	var height1 = ticks_height * height_multiplier / camera.zoom.x
	var height2 = (ticks_height + 2) * height_multiplier / camera.zoom.x
	if p.y == 0.0:
		draw_line(s + Vector2(0, -height2), s + Vector2(0, height2), Color.WHITE, (main_lines_weight + 2) / camera.zoom.x)
		draw_line(s + Vector2(0, -height1), s + Vector2(0, height1), Color.BLACK, main_lines_weight / camera.zoom.x)

	elif p.x == 0.0:
		draw_line(s + Vector2(-height2, 0), s + Vector2(height2, 0), Color.WHITE, (main_lines_weight + 2) / camera.zoom.y)
		draw_line(s + Vector2(-height1, 0), s + Vector2(height1, 0), Color.BLACK, main_lines_weight / camera.zoom.y)


func fractal_pos_to_screen_pos(p: Vector2) -> Vector2:
	var fractal_offset = fractal.material.get_shader_parameter("offset")
	var fractal_scale = fractal.material.get_shader_parameter("scale")
	return size / 2. + (p + fractal_offset) * fractal_scale * Vector2(fractal.size)
