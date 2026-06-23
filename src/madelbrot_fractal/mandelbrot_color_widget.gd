extends Control

enum GradMappingConfig {DISABLED, HSV, ANGLE, MAG}

var DEFAULT_GRADIENT_ATENUATION = 1.0
var GRADIENT_MAPPING_ATTENUATION = 8.0

@export var default_grad_index = 0

var POPUP_MENU_OFFSET = Vector2(1, -4)

@export var gradients : Array[Gradient]
@export var gradients_names : Array[String]
var GRADIENT_SIZE_IN_MENU = Vector2(181, 22)

var LABEL_DISABLED_COLOR = Color(0.7, 0.7, 0.7, 1.0)

func _ready() -> void:
	MandelbrotConfig.grad = gradients[default_grad_index]

	%gradient_attenuation.initial_value = DEFAULT_GRADIENT_ATENUATION
	%gradient_attenuation.set_value(DEFAULT_GRADIENT_ATENUATION)
	%GradientSelector.set_gradient(MandelbrotConfig.grad)
	%ColorPickerButton.color = MandelbrotConfig.color

	load_gradients()
	update_gradient(default_grad_index) 


func load_gradients() -> void:
	for grad in gradients:
		var id = %PopupMenu.item_count

		var grad_texture = GradientTexture2D.new()
		grad_texture.gradient = grad
		grad_texture.width = GRADIENT_SIZE_IN_MENU.x
		grad_texture.height = GRADIENT_SIZE_IN_MENU.y

		var label = gradients_names[id - 1] # I subtract one because the element 0 is the title
		%PopupMenu.add_icon_item(grad_texture, "  " + label, id)

func capitalize_gradient_name(s: String) -> String:
	if s == "":
		return ""

	s[0] = s[0].capitalize()
	for i in range(len(s)):
		if s[i] == "_":
			s[i] = " "
			if i < len(s) - 1:
				s[i + 1] = s[i + 1].capitalize()
				
		elif s[i] == "-":
			s[i + 1] = s[i + 1].capitalize()

	return s


func set_gradient_repetition_initial_value(val: float) -> void:
	%gradient_repetition.initial_value = val

func set_gradient_repetition_target_value(val: float) -> void:
	%gradient_repetition.set_value(val)


func _process(_delta: float) -> void:
	MandelbrotConfig.grad = %GradientSelector.grad
	MandelbrotConfig.color = %ColorPickerButton.color
	MandelbrotConfig.grad_attenuation = %gradient_attenuation.get_value()
	MandelbrotConfig.grad_repetition = %gradient_repetition.get_value()
	MandelbrotConfig.smooth_grad = %smoothened_gradient_checkbox.button_pressed
	MandelbrotConfig.grad_mapping_inverted = %grad_mapping_inverted_checkbox.button_pressed
	MandelbrotConfig.color_inside = %color_inside_checkbox.button_pressed

	MandelbrotConfig.grad_mapping = false
	MandelbrotConfig.color_with_angle = false
	MandelbrotConfig.color_with_mag = false

	
	if %gradient_mapping_button.selected == GradMappingConfig.DISABLED:
		%grad_mapping_inverted_label.add_theme_color_override("font_color", LABEL_DISABLED_COLOR)
		%grad_mapping_inverted_checkbox.disabled = true
		
	else:
		%grad_mapping_inverted_label.add_theme_color_override("font_color", Color.WHITE)
		%grad_mapping_inverted_checkbox.disabled = false
		MandelbrotConfig.grad_mapping = true
	
	match %gradient_mapping_button.selected:
		GradMappingConfig.ANGLE:
			%gradient_attenuation.set_disabled(true)
			MandelbrotConfig.color_with_angle = true
		GradMappingConfig.MAG:
			%gradient_attenuation.set_disabled(false)
			MandelbrotConfig.color_with_mag = true
		_:
			%gradient_attenuation.set_disabled(false)
		
	%PopupMenu.position = %gradient_menu_button.global_position +  Vector2(%gradient_menu_button.size.x - 3, %gradient_menu_button.size.y / 2.)
	%PopupMenu.position += Vector2i(0, -%PopupMenu.size.y / 2.)



func _on_gradient_mapping_checkbox_toggled(toggled_on: bool) -> void:
	var attenuation = GRADIENT_MAPPING_ATTENUATION if toggled_on else DEFAULT_GRADIENT_ATENUATION
	%gradient_attenuation.initial_value = attenuation
	%gradient_attenuation.set_value(attenuation)




func _on_gradient_menu_button_toggled(toggled_on: bool) -> void:
	%PopupMenu.visible = toggled_on


func _on_popup_menu_index_pressed(index: int) -> void:
	%gradient_menu_button.button_pressed = false
	update_gradient(index - 1) # I subtract one because the element 0 is the title


func update_gradient(index: int)-> void:
	MandelbrotConfig.grad = gradients[index]
	%GradientSelector.set_gradient(MandelbrotConfig.grad)


func _on_gradient_mapping_button_item_selected(index: int) -> void:
	if index == GradMappingConfig.DISABLED:
		%gradient_attenuation.initial_value = DEFAULT_GRADIENT_ATENUATION
		%gradient_attenuation.set_value(DEFAULT_GRADIENT_ATENUATION)
	else:
		%gradient_attenuation.initial_value = GRADIENT_MAPPING_ATTENUATION
		%gradient_attenuation.set_value(GRADIENT_MAPPING_ATTENUATION)
