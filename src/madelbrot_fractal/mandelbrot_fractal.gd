extends ColorRect

var OFFSET_JULIA = Vector2.ZERO
var OFFSET_MANDELBROT = Vector2(0.5, 0.0);


func _ready() -> void:
	%z.set_shader_parameter("exponent", Vector2(2.0, 0.0))
	%constant.set_shader_parameter("exponent", Vector2(2.0, 0.0))
	%exp.set_shader_parameter("exponent", Vector2(2.0, 0.0))

	
func _process(_delta: float) -> void:
	$CanvasLayer.visible = visible
	
	var julia = %julia.get_node("julia_checkbox").button_pressed

	%z.set_disabled(julia)
	%z.get_node("InOutWidget").set_button_disabled(julia)
	%constant.set_disabled(!julia)
	%constant.get_node("InOutWidget").set_button_disabled(!julia)

	material.set_shader_parameter("iterations", %iterations.get_value())
	material.set_shader_parameter("julia", julia)
	material.set_shader_parameter("burning_ship", %burning_ship_checkbox.button_pressed)
	%z.set_shader_parameter("burning_ship", %burning_ship_checkbox.button_pressed)
	%constant.set_shader_parameter("burning_ship", %burning_ship_checkbox.button_pressed)
	material.set_shader_parameter("offset", OFFSET_JULIA if julia else OFFSET_MANDELBROT)
	material.set_shader_parameter("constant_c", %constant.get_complex_num())
	material.set_shader_parameter("initial_z",%z.get_complex_num())
	material.set_shader_parameter("exponent", %exp.get_complex_num())
