extends Control


@onready var texture = preload("res://assets/sprites/sierpinski_triangle.png")
var ITERATIONS_ON_TEXTURE = 8

const FIRST_TRIANGLE_POS = Vector2(0.5, 0.5)
@onready var TRIANGLE_WIDTH = size.y * 2 / sqrt(3)

@export var color := Color.WHITE
@export var bg_color := Color.BLACK

@onready var bg = $bg


var iterations : int = 10
var prev_iterations = iterations

func _ready() -> void:
	bg.color = bg_color


func _process(_delta: float) -> void:
	if prev_iterations != iterations:
		queue_redraw()
	
	prev_iterations = iterations


func _draw() -> void:
	RenderingServer.canvas_item_set_default_texture_filter(
		get_canvas_item(),
		RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	)

	draw_fractal(iterations - ITERATIONS_ON_TEXTURE, FIRST_TRIANGLE_POS * size)


func draw_fractal(depth: int, prev_pos: Vector2, iteration = 2) -> void:
	var child_positions = get_child_triangles_positions(iteration, prev_pos)
	for pos in child_positions:
		if depth <= 0:
			if iteration >= depth + ITERATIONS_ON_TEXTURE:
				draw_triangle(pos, size.y / (1 << (iteration)))
			else:
				draw_fractal(depth, pos, iteration + 1)	
		elif iteration >= depth:
			draw_texture_triangle(pos, size.y / (1 << (iteration)))
		else:
			draw_fractal(depth, pos, iteration + 1)	


func get_child_triangles_positions(i: int, prev_pos: Vector2) -> PackedVector2Array:
	var s = 1./(1 << (i+1))
	return [
		Vector2(TRIANGLE_WIDTH * s, size.y * s) + prev_pos,
		Vector2(TRIANGLE_WIDTH * -s, size.y * s) + prev_pos,
		Vector2(0, -size.y * s) + prev_pos
	]


func draw_texture_triangle(pos: Vector2, h: float) -> void:
	var new_texture_size = Vector2(texture.get_size().x * h / texture.get_size().y, h)
	draw_texture_rect(
		texture,
		Rect2(pos - new_texture_size / 2.0, new_texture_size),
		false
	)

func draw_triangle(pos: Vector2, h: float) -> void:
	var positions = [
		Vector2(0, -h / 2.0) + pos,
		Vector2(h /sqrt(3), h / 2.0) + pos,
		Vector2(-h /sqrt(3), h / 2.0) + pos,
	]
	draw_polygon(positions, [Color.WHITE])

