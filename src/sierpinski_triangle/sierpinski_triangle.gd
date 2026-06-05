extends Control

const FIRST_TRIANGLE_POS = Vector2(0.5, 0.75)
@onready var TRIANGLE_WIDTH = size.y * 2 / sqrt(3)

@export var color := Color.WHITE
@export var bg_color := Color.BLACK

@onready var bg = $bg


var iterations : int = 8

func _ready() -> void:
	bg.color = bg_color
	
	
func _draw() -> void:
	draw_triangle(size / 2.0, size.y)
	draw_inverted_triangle(FIRST_TRIANGLE_POS * size, size.y / 2.0)

	draw_fractal(iterations, FIRST_TRIANGLE_POS * size)


func draw_fractal(depth: int, prev_pos: Vector2, iteration = 2) -> void:
	if iteration > depth:
		return

	var child_positions = get_child_triangles_positions(iteration, prev_pos)
	for pos in child_positions:
		draw_inverted_triangle(pos, size.y / (1 << (iteration)))

		draw_fractal(depth, pos, iteration + 1)	


func get_child_triangles_positions(i: int, prev_pos: Vector2) -> PackedVector2Array:
	var s = 1./(1 << i)
	var t = 1./(1 << (i+1))
	return [
		Vector2(TRIANGLE_WIDTH * s, size.y * t) + prev_pos,
		Vector2(TRIANGLE_WIDTH * -s, size.y * t) + prev_pos,
		Vector2(0, -size.y * (s + t)) + prev_pos
	]


func draw_triangle(pos: Vector2, h: float) -> void:
	draw_polygon(get_triangle_positions(pos, h), [color])


func draw_inverted_triangle(pos: Vector2, h: float) -> void:
	draw_polygon(get_inverted_triangle_positions(pos, h), [bg_color])


func get_triangle_positions(pos: Vector2, h: float) -> PackedVector2Array:
	var half_w := h / sqrt(3)

	return [
		pos + Vector2(0, -h / 2.0),
		pos + Vector2(half_w, h / 2.0),
		pos + Vector2(-half_w, h / 2.0)
	]


func get_inverted_triangle_positions(pos: Vector2, h: float) -> PackedVector2Array:
	var half_w := h / sqrt(3)

	return [
		pos + Vector2(0, h / 2.0),
		pos + Vector2(-half_w, -h / 2.0),
		pos + Vector2(half_w, -h / 2.0)
	]
