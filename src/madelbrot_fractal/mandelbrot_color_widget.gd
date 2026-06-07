extends Control

func _ready() -> void:
	%GradientSelector.set_gradient(Global.mandelbrot_grad)

func _process(_delta: float) -> void:
	Global.mandelbrot_grad = %GradientSelector.grad
	Global.mandelbrot_color = %ColorPickerButton.color
	Global.mandelbrot_grad_attenuation = %gradient_attenuation.get_value()
	Global.mandelbrot_grad_repetition = %gradient_repetition.get_value()
	Global.mandelbrot_smooth_grad = %smoothened_gradient_checkbox.button_pressed
