extends ColorRect

var zoom = 0.5
var auto_iterations = true

func _process(delta: float) -> void:
	var iterations = 1
	var auto_iterations = %auto_iterations_checkbox.button_pressed
	if auto_iterations:
		%iterations.set_disabled(true)
		iterations = min(25, roundi(log2(zoom)) + 10)
	else:
		%iterations.set_disabled(false)
		iterations = %iterations.get_value()
		
	material.set_shader_parameter("iterations", iterations)

func log2(n: float) -> float:
	return log(n) / log(2)
