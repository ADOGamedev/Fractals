extends ColorRect

var OFFSET_JULIA = Vector2.ZERO
var OFFSET_MANDELBROT = Vector2(0.5, 0.0);

func _process(_delta: float) -> void:
	var julia = %julia.get_node("julia_checkbox").button_pressed
	material.set_shader_parameter("iterations", %iterations.get_value())
	material.set_shader_parameter("julia", julia)
	material.set_shader_parameter("offset", OFFSET_JULIA if julia else OFFSET_MANDELBROT)
	material.set_shader_parameter("constant_c", Vector2(%constant_r.get_value(), %constant_i.get_value()))
	material.set_shader_parameter("exponent", %exp.get_value())
