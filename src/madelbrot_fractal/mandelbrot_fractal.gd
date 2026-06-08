extends ColorRect

var OFFSET_MANDELBROT = Vector2(0.7, 0.0)
var OFFSET_BURNING_SHIP = Vector2(0.5, 0.5)

var DEFAULT_SCALE = 0.4
var SCALE_RINGS_FRACTAL = 0.1
var SCALE_JULIA_RINGS_FRACTAL = 0.2

var Z_RINGS_FRACTAL = Vector2(1.0, 0.0)
var C_RINGS_FRACTAL = Vector2(sqrt(2), 0.0)
var Z_MANDELBROT = Vector2(0.0, 0.0)
var C_MANDELBROT = Vector2(-0.76133, 0.07555)
var Z_BURNING_SHIP = Vector2(0.0, 0.0)
var C_BURNING_SHIP = Vector2(-0.4384, 0.07305)

var DEFAULT_EXPONENT = Vector2(2.0, 0.0)


func _ready() -> void:
	%z.set_shader_parameter("exponent", DEFAULT_EXPONENT)
	%constant.set_shader_parameter("exponent", DEFAULT_EXPONENT)

	%MandelbrotColorWidget.set_gradient_repetition_target_value(%iterations.get_value())

	
func _process(_delta: float) -> void:
	if !visible:
		$CanvasLayer.visible = false

	set_complex_selectors_parameters()
	disable_complex_selectors_accordingly()
	set_main_fractal_parameters()

	%MandelbrotColorWidget.set_gradient_repetition_initial_value(%iterations.get_value())


func set_complex_selectors_parameters() -> void:
	var burning_ship = %burning_ship_checkbox.button_pressed
	var rings_fractal = %rings_fractal_checkbox.button_pressed

	var exponent = Vector2(%exp_r.get_value(), %exp_i.get_value())

	%z.set_shader_parameter("burning_ship", burning_ship)
	%constant.set_shader_parameter("burning_ship", burning_ship)

	%z.set_shader_parameter("rings_fractal", rings_fractal)
	%constant.set_shader_parameter("rings_fractal", rings_fractal)

	%z.set_shader_parameter("exponent", exponent)
	%constant.set_shader_parameter("exponent", exponent)

	var offset = OFFSET_MANDELBROT
	if burning_ship:
		offset = OFFSET_BURNING_SHIP

	%z.set_shader_parameter("offset", offset)
	%constant.set_shader_parameter("offset", offset)


func disable_complex_selectors_accordingly() -> void:
	var julia = %julia_checkbox.button_pressed

	%z.set_disabled(julia)
	%z.get_node("InOutWidget").set_button_disabled(julia)
	%constant.set_disabled(!julia)
	%constant.get_node("InOutWidget").set_button_disabled(!julia)


func set_main_fractal_parameters() -> void:
	material.set_shader_parameter("iterations", %iterations.get_value())

	material.set_shader_parameter("set_color", Global.mandelbrot_color)
	material.set_shader_parameter("gradient_attenuation", Global.mandelbrot_grad_attenuation)
	material.set_shader_parameter("gradient_repetition", Global.mandelbrot_grad_repetition)
	material.set_shader_parameter("smooth_grad", Global.mandelbrot_smooth_grad)
	material.set_shader_parameter("gradient_mapping", Global.mandelbrot_grad_mapping)
	material.set_shader_parameter("glow_rainbow", Global.mandelbrot_glow_rainbow)

	var grad_tex = GradientTexture2D.new()
	grad_tex.gradient = Global.mandelbrot_grad
	material.set_shader_parameter("gradient", grad_tex)
	
	var julia = %julia_checkbox.button_pressed
	var burning_ship = %burning_ship_checkbox.button_pressed
	var rings_fractal = %rings_fractal_checkbox.button_pressed

	material.set_shader_parameter("julia", julia)
	material.set_shader_parameter("burning_ship", burning_ship)
	material.set_shader_parameter("rings_fractal", rings_fractal)

	var offset = OFFSET_MANDELBROT
	if julia or rings_fractal:
		offset = Vector2.ZERO
	elif burning_ship:
		offset = OFFSET_BURNING_SHIP

	material.set_shader_parameter("offset", offset)

	material.set_shader_parameter("constant_c", %constant.get_complex_num())
	material.set_shader_parameter("initial_z",%z.get_complex_num())

	var exponent = Vector2(%exp_r.get_value(), %exp_i.get_value())
	material.set_shader_parameter("exponent", exponent)

	if rings_fractal:
		var fractal_scale = SCALE_JULIA_RINGS_FRACTAL if julia else SCALE_RINGS_FRACTAL
		material.set_shader_parameter("scale", fractal_scale)
	else:
		material.set_shader_parameter("scale", DEFAULT_SCALE)


func update_widgets_values() -> void:
	var burning_ship = %burning_ship_checkbox.button_pressed
	var rings_fractal = %rings_fractal_checkbox.button_pressed

	var z_value = Z_MANDELBROT
	var c_value = C_MANDELBROT
	if rings_fractal:
		z_value = Z_RINGS_FRACTAL
		c_value = C_RINGS_FRACTAL
	elif burning_ship:
		z_value = Z_BURNING_SHIP
		c_value = C_BURNING_SHIP

	%z.set_target_complex_num(z_value)
	%z.set_initial_complex_num(z_value)
	%constant.set_target_complex_num(c_value)
	%constant.set_initial_complex_num(c_value)


func _on_rings_fractal_checkbox_pressed() -> void:
	update_widgets_values()

func _on_burning_ship_checkbox_pressed() -> void:
	update_widgets_values()

func _on_julia_checkbox_pressed() -> void:
	update_widgets_values()
