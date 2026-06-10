extends Control

@export var main_lines_weight = 2
@export var ticks_height = 6


func _process(delta: float) -> void:
    queue_redraw()


func fractal_pos_to_screen_pos(p: Vector2) -> Vector2:
    var fractal_scale = %fractal.material.get_shader_parameter("scale")
    var offset = %fractal.material.get_shader_parameter("offset")
    var zoom = %Camera2D.zoom.x
    var camera_pos = %Camera2D.position - size / 2.
    var center = size / 2.0
    
    return (p + offset) * %fractal.size * fractal_scale * zoom + center - camera_pos * zoom


func _draw() -> void:
    var origin = fractal_pos_to_screen_pos(Vector2.ZERO)


    if !point_out_of_bounds(Vector2(0, origin.y)):
        draw_line(Vector2(0, origin.y), Vector2(size.x, origin.y), Color.WHITE, main_lines_weight + 2)
        draw_line(Vector2(0, origin.y), Vector2(size.x, origin.y), Color.BLACK, main_lines_weight)
    
    if !point_out_of_bounds(Vector2(origin.x, 0)):
        draw_line(Vector2(origin.x, 0), Vector2(origin.x, size.y), Color.WHITE, main_lines_weight + 2)
        draw_line(Vector2(origin.x, 0), Vector2(origin.x, size.y), Color.BLACK, main_lines_weight)

    for i in range(-4, 6):
        var weight_mult = 1.0 if (i % 2 == 0) else 0.5
        draw_marker(Vector2(i/2., 0), weight_mult)
        draw_marker(Vector2(0, i/2.), weight_mult)


func draw_marker(p: Vector2, height_multiplier = 1.0) -> void:
    var s = fractal_pos_to_screen_pos(p)
    if p == Vector2.ZERO or point_out_of_bounds(s):
        return

    var height1 = ticks_height * height_multiplier
    var height2 = (ticks_height + 2) * height_multiplier
    if p.y == 0.0:
        draw_line(s + Vector2(0, -height2), s + Vector2(0, height2), Color.WHITE, main_lines_weight + 2)
        draw_line(s + Vector2(0, -height1), s + Vector2(0, height1), Color.BLACK, main_lines_weight)
    elif p.x == 0.0:
        draw_line(s + Vector2(-height2, 0), s + Vector2(height2, 0), Color.WHITE, main_lines_weight + 2)
        draw_line(s + Vector2(-height1, 0), s + Vector2(height1, 0), Color.BLACK, main_lines_weight)


func point_out_of_bounds(p: Vector2) -> bool:
    return p.x < 0 or p.y < 0 or p.x > size.x or p.y > size.y