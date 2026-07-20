extends Control

@onready var panel := $PanelContainer
@onready var secondary := %secondary_label

@export var image : Texture2D
@export_multiline var label : String
@export_multiline var secondary_label : String
@export var scene : PackedScene

var tint : Color = Color.BLACK
var hover_tint : Color = Color("#56585a4e")

var contracted_height : float
var extended_height : float

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.size.y = 0 # I force the Y size to be the minimum
	contracted_height = panel.size.y

	tint = panel.material.get_shader_parameter("tint")
	%image.texture = image
	%Label.text = label
	secondary.text = secondary_label

	secondary.visible = true
	await get_tree().process_frame

	extended_height = contracted_height + secondary.get_combined_minimum_size().y

	secondary.visible = false

	mouse_filter = Control.MOUSE_FILTER_STOP



func _on_panel_container_mouse_entered() -> void:
	z_index += 1

	var tween = get_tree().create_tween().set_parallel(true)

	tween.tween_property(panel.material, "shader_parameter/tint", hover_tint, 0.1)
	tween.tween_property(panel, "size:y", extended_height, 0.1)

	tween.chain()

	tween.tween_callback(Callable(self, "_show_secondary"))

	tween.tween_property(secondary, "modulate", Color.WHITE, 0.1)


func _on_panel_container_mouse_exited() -> void:
	z_index -= 1

	var tween = get_tree().create_tween().set_parallel(true)

	tween.tween_property(secondary, "modulate", Color.TRANSPARENT, 0.1)

	tween.chain()

	tween.tween_property(panel.material, "shader_parameter/tint", tint, 0.1)
	tween.tween_property(panel, "size:y", contracted_height, 0.1)

	tween.tween_callback(Callable(self, "_hide_secondary"))


func _on_panel_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		await Gradients.gradients_ready
		get_tree().change_scene_to_packed(scene)


func _show_secondary():
	if not is_inside_tree():
		return
	secondary.visible = true

func _hide_secondary():
	if not is_inside_tree():
		return
	secondary.visible = false