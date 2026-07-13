extends ColorRect

var auto_iterations = true
var DEFAULT_CAMERA_ZOOM = Vector2.ONE

func _process(_delta: float) -> void:
	Global.current_shader_material = material
	
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")

	update_main_fractal_parameters()
	update_color_fractal_parameters()


func update_main_fractal_parameters() -> void:
	var zoom = $Camera2D.zoom.x

	if !visible:
		$CanvasLayer.visible = false

	var auto_scale = %auto_scale_checkbox.button_pressed
	var fractal_scale = %scale.get_value()
	if auto_scale:
		fractal_scale = get_auto_scale()
		%scale.set_value(fractal_scale)

	%scale.set_disabled(auto_scale)
		
	var iterations = 1
	auto_iterations = %auto_iterations_checkbox.button_pressed

	if auto_iterations:
		%iterations.set_disabled(true)
		iterations = min(25, roundi(log_base(1 / fractal_scale, zoom)) + 13 - roundi(%sides.get_value() / 2.))
		%iterations.set_value(iterations)
	else:
		%iterations.set_disabled(false)
		iterations = %iterations.get_value()


		
	material.set_shader_parameter("iterations", iterations)

	material.set_shader_parameter("sides", %sides.get_value())
	material.set_shader_parameter("include_center", %include_center_checkbox.button_pressed)
	material.set_shader_parameter("auto_scale", %auto_scale_checkbox.button_pressed)
	material.set_shader_parameter("scale", fractal_scale)

	
func update_color_fractal_parameters() -> void:
	var grad_tex = GradientTexture2D.new()
	grad_tex.gradient = NFlakeConfig.grad
	material.set_shader_parameter("gradient", grad_tex)

	material.set_shader_parameter("color", NFlakeConfig.color)
	material.set_shader_parameter("bg_color", NFlakeConfig.bg_color)
	material.set_shader_parameter("gradient_attenuation", NFlakeConfig.grad_attenuation)
	material.set_shader_parameter("gradient_repetition", NFlakeConfig.grad_repetition)
	material.set_shader_parameter("negative_space", NFlakeConfig.negative_space)
	material.set_shader_parameter("color_by_position", NFlakeConfig.color_by_position)
	material.set_shader_parameter("color_by_iterations", NFlakeConfig.color_by_iterations)
	material.set_shader_parameter("color_by_overlap", NFlakeConfig.color_by_overlap)
	material.set_shader_parameter("color_by_distance", NFlakeConfig.color_by_distance)
	material.set_shader_parameter("sdf_coloring", NFlakeConfig.sdf_coloring)


func get_auto_scale() -> float:
	var sides = %sides.get_value()
	var s = 1.;
	var limit = floori(sides / 4.);
	
	for k in range(1, limit + 1):
		s += cos(2. * PI * k / sides);
	
	s *= 2.;
	return 1. / s;


func log_base(base: float, n: float) -> float:
	return log(n) / log(base)


func _on_utilities_panel_restart_camera() -> void:
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($Camera2D, "zoom", DEFAULT_CAMERA_ZOOM, 0.1)
	tween.tween_property($Camera2D, "position", size / 2., 0.1)


