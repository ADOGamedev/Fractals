extends Control

@export var image : Texture2D
@export_multiline var label : String
@export_multiline var secondary_label : String
@export var scene : PackedScene

var tint : Color = Color.BLACK
var hover_tint : Color = Color("#56585a4e")

var extended_size : Vector2
var contracted_size : Vector2

func _ready() -> void:
	$PanelContainer.size.y = 0 # I force the Y size to be the minimum
	contracted_size = $PanelContainer.size

	tint = $PanelContainer.material.get_shader_parameter("tint")
	%image.texture = image
	%Label.text = label
	%secondary_label.text = secondary_label

	%secondary_label.visible = true
	await get_tree().process_frame
	var extra = %secondary_label.get_combined_minimum_size().y
	extended_size = contracted_size + Vector2(0, extra)

	%secondary_label.visible = false



func _on_panel_container_mouse_entered() -> void:
	z_index += 1
	
	var tween = get_tree().create_tween().set_parallel(true)

	tween.tween_property($PanelContainer.material, "shader_parameter/tint", hover_tint, 0.1)
	tween.tween_property($PanelContainer, "size", extended_size, 0.1)

	tween.chain()

	tween.tween_callback(func():
		%secondary_label.visible = true
	)

	tween.tween_property(%secondary_label, "modulate", Color.WHITE, 0.1)


func _on_panel_container_mouse_exited() -> void:
	z_index -= 1

	var tween = get_tree().create_tween().set_parallel(true)

	tween.tween_property(%secondary_label, "modulate", Color.TRANSPARENT, 0.1)

	tween.chain()

	tween.tween_property($PanelContainer.material, "shader_parameter/tint", tint, 0.1)
	tween.tween_property($PanelContainer, "size", contracted_size, 0.1)

	tween.tween_callback(func():
		%secondary_label.visible = false
	)


func _on_panel_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_packed(scene)