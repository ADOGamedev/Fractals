extends Node

var mandelbrot_grad = preload("res://assets/gradients/rainbow_gradient.tres")
var mandelbrot_color = Color.WHITE
var mandelbrot_grad_attenuation = 0.36
var mandelbrot_grad_repetition = 500.0
var mandelbrot_smooth_grad = true
var mandelbrot_grad_mapping = false
var mandelbrot_glow_rainbow = false

var ui_hidden = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hide_ui"):
		ui_hidden = !ui_hidden
		get_tree().call_group("canvas_layer", "hide" if ui_hidden else "show")
		

