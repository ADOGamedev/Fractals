extends Node

var ui_hidden = false
var file_saver_scene = preload("res://scenes/image_saver.tscn")
var img_saver

var current_shader_material : ShaderMaterial = null

var prev_windows_mode = DisplayServer.WINDOW_MODE_MAXIMIZED


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		toggle_fullscreen()

	if Input.is_action_just_pressed("hide_ui"):
		toggle_canvas_layers_visibility()

	if Input.is_action_just_pressed("save_img") and img_saver == null and current_shader_material != null:
		save_img_pressed()



func toggle_fullscreen() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(prev_windows_mode)
	else:
		prev_windows_mode = mode
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func toggle_canvas_layers_visibility() -> void:
	ui_hidden = !ui_hidden
	get_tree().call_group("canvas_layer", "show" if !ui_hidden else "hide")


func save_img_pressed() -> void:
	img_saver = file_saver_scene.instantiate()
	get_tree().root.add_child(img_saver)