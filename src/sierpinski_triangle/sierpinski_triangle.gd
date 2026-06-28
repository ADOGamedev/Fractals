extends ColorRect

var auto_iterations = true

func _process(_delta: float) -> void:
	update_iterations()
	set_main_fractal_parameters()


func update_iterations() -> void:
	var zoom = $Camera2D.zoom.x

	if !visible:
		$CanvasLayer.visible = false
		
	var iterations = 1
	auto_iterations = %auto_iterations_checkbox.button_pressed

	if auto_iterations:
		%iterations.set_disabled(true)
		iterations = min(25, roundi(log2(zoom)) + 10)
		%iterations.set_value(iterations)
	else:
		%iterations.set_disabled(false)
		iterations = %iterations.get_value()
		
	material.set_shader_parameter("iterations", iterations)

	
func set_main_fractal_parameters() -> void:
	var grad_tex = GradientTexture2D.new()
	grad_tex.gradient = SierpinskiConfig.grad
	material.set_shader_parameter("gradient", grad_tex)

	material.set_shader_parameter("color", SierpinskiConfig.color)
	material.set_shader_parameter("bg_color", SierpinskiConfig.bg_color)
	material.set_shader_parameter("gradient_attenuation", SierpinskiConfig.grad_attenuation)
	material.set_shader_parameter("gradient_repetition", SierpinskiConfig.grad_repetition)
	material.set_shader_parameter("negative_space", SierpinskiConfig.negative_space)
	material.set_shader_parameter("color_by_position", SierpinskiConfig.color_by_position)
	material.set_shader_parameter("color_by_iterations", SierpinskiConfig.color_by_iterations)



func log2(n: float) -> float:
	return log(n) / log(2)
