extends Node

var ui_hidden = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hide_ui"):
		ui_hidden = !ui_hidden
		get_tree().call_group("canvas_layer", "hide" if ui_hidden else "show")
		

