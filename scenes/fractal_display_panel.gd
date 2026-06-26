extends Control

@export var image : Texture2D
@export var label : String
@export var scene : PackedScene

var tint : Color = Color.BLACK
var hover_tint : Color = Color("#56585a4e")

func _ready() -> void:
	tint = $PanelContainer.material.get_shader_parameter("tint")
	%image.texture = image
	%Label.text = label


func _on_panel_container_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($PanelContainer.material, "shader_parameter/tint", hover_tint, 0.1)

func _on_panel_container_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($PanelContainer.material, "shader_parameter/tint", tint, 0.1)

func _on_panel_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_packed(scene)