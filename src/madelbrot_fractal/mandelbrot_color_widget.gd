extends Control

var DEFAULT_GRADIENT_ATENUATION = 1.0
var GRADIENT_MAPPING_ATTENUATION = 8.0

func _ready() -> void:
	%gradient_attenuation.initial_value = DEFAULT_GRADIENT_ATENUATION
	%gradient_attenuation.set_value(DEFAULT_GRADIENT_ATENUATION)
	%GradientSelector.set_gradient(Global.mandelbrot_grad)

func set_gradient_repetition_initial_value(val: float) -> void:
	%gradient_repetition.initial_value = val

func set_gradient_repetition_target_value(val: float) -> void:
	%gradient_repetition.set_value(val)


func _process(_delta: float) -> void:
	Global.mandelbrot_grad = %GradientSelector.grad
	Global.mandelbrot_color = %ColorPickerButton.color
	Global.mandelbrot_grad_attenuation = %gradient_attenuation.get_value()
	Global.mandelbrot_grad_repetition = %gradient_repetition.get_value()
	Global.mandelbrot_smooth_grad = %smoothened_gradient_checkbox.button_pressed
	Global.mandelbrot_grad_mapping = %gradient_mapping_checkbox.button_pressed
	Global.mandelbrot_glow_rainbow = %glow_rainbow_checkbox.button_pressed



func _on_gradient_mapping_checkbox_toggled(toggled_on: bool) -> void:
	var attenuation = GRADIENT_MAPPING_ATTENUATION if toggled_on else DEFAULT_GRADIENT_ATENUATION
	%gradient_attenuation.initial_value = attenuation
	%gradient_attenuation.set_value(attenuation)


