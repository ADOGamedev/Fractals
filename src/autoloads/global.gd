extends Node

var ui_hidden = false
var file_saver_scene = preload("res://scenes/image_saver.tscn")
var img_saver

var current_shader_material : ShaderMaterial = null

var prev_windows_mode = DisplayServer.WINDOW_MODE_MAXIMIZED


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		var mode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(prev_windows_mode)
		else:
			prev_windows_mode = mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	if Input.is_action_just_pressed("hide_ui"):
		ui_hidden = !ui_hidden
		set_canvas_layers_visibility(!ui_hidden)

	if Input.is_action_just_pressed("screenshot") and img_saver == null and current_shader_material != null:
		img_saver = file_saver_scene.instantiate()
		get_tree().root.add_child(img_saver)


func set_canvas_layers_visibility(visible: bool) -> void:
	get_tree().call_group("canvas_layer", "show" if visible else "hide")

