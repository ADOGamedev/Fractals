extends Control

var orthogonal = false
var fov = 45


func _process(delta: float) -> void:
	fov = %fov.get_value()

func _on_orthogonal_view_checkbox_toggled(toggled_on: bool) -> void:
	orthogonal = toggled_on
