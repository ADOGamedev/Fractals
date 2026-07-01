extends Control

signal restart_camera


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("show_fps"):
		$fps.visible = !$fps.visible

	if $fps.visible:
		$fps.text = str(Engine.get_frames_per_second()) + " FPS"


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_exit_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($close_fractal_panel, "modulate", Color(1, 1, 1, 1), 0.15)

func _on_exit_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($close_fractal_panel, "modulate", Color(1, 1, 1, 0), 0.15)



func _on_restart_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($reset_panel, "modulate", Color(1, 1, 1, 1), 0.15)

func _on_restart_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($reset_panel, "modulate", Color(1, 1, 1, 0), 0.15)


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()



func _on_restart_camera_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($reset_camera_panel, "modulate", Color(1, 1, 1, 1), 0.15)

func _on_restart_camera_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($reset_camera_panel, "modulate", Color(1, 1, 1, 0), 0.15)

func _on_restart_camera_button_pressed() -> void:
	emit_signal("restart_camera")



func _on_save_img_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($save_img_panel, "modulate", Color(1, 1, 1, 1), 0.15)

func _on_save_img_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($save_img_panel, "modulate", Color(1, 1, 1, 0), 0.15)

func _on_save_img_button_pressed() -> void:
	Global.save_img_pressed()
