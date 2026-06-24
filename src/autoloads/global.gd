extends Node

var ui_hidden = false
var file_dialog : FileDialog
var current_image : Image


func _ready() -> void:
	file_dialog = FileDialog.new()
	file_dialog.use_native_dialog = true

	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE

	file_dialog.title = "Save your fractal screenshot"

	file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)

	file_dialog.file_selected.connect(_on_file_dialog_file_selected)

	add_child(file_dialog)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hide_ui"):
		ui_hidden = !ui_hidden
		set_canvas_layers_visibility(!ui_hidden)

	if Input.is_action_just_pressed("screenshot"):
		set_canvas_layers_visibility(false)
		await get_tree().process_frame

		current_image = get_viewport().get_texture().get_image()

		set_canvas_layers_visibility(!ui_hidden)

		file_dialog.current_file = "my_fractal.png"
		file_dialog.popup_centered()


func set_canvas_layers_visibility(visible: bool) -> void:
	get_tree().call_group("canvas_layer", "show" if visible else "hide")


func _on_file_dialog_file_selected(path: String):
	if current_image:
		current_image.save_png(path)
		
