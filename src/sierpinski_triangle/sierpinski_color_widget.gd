extends Control


enum ColoringMethod {PLAIN, HUE, GRADIENT}

var DEFAULT_GRADIENT_ATENUATION = 1.0
var GRADIENT_MAPPING_ATTENUATION = 8.0

@export var default_grad_index = 0

@export var gradients : Array[Gradient]
@export var gradients_names : Array[String]
var GRADIENT_SIZE_IN_MENU = Vector2(181, 22)


func _ready() -> void:
	load_gradients()
	
	SierpinskiConfig.grad = gradients[default_grad_index]

	%gradient_attenuation.initial_value = DEFAULT_GRADIENT_ATENUATION
	%gradient_attenuation.set_value(DEFAULT_GRADIENT_ATENUATION)
	%GradientSelector.set_gradient(SierpinskiConfig.grad)
	%ColorPickerButton.color = SierpinskiConfig.color

	update_gradient(default_grad_index) 



func _process(_delta: float) -> void:
	SierpinskiConfig.grad = %GradientSelector.grad
	SierpinskiConfig.bg_color = %BGColorPickerButton.color
	SierpinskiConfig.color = %ColorPickerButton.color
	SierpinskiConfig.grad_attenuation = %gradient_attenuation.get_value()
	SierpinskiConfig.grad_repetition = %gradient_repetition.get_value()	

	SierpinskiConfig.negative_space = %negative_space_checkbox.button_pressed

	SierpinskiConfig.color_by_position = false
	SierpinskiConfig.color_by_iterations = false

	match %coloring_method_button.selected:
		ColoringMethod.PLAIN:
			pass
		ColoringMethod.HUE:
			SierpinskiConfig.color_by_position = true
		ColoringMethod.GRADIENT: 
			SierpinskiConfig.color_by_iterations = true

	%PopupMenu.position = %gradient_menu_button.global_position +  Vector2(%gradient_menu_button.size.x - 3, %gradient_menu_button.size.y / 2.)
	%PopupMenu.position += Vector2i(0, -%PopupMenu.size.y / 2.)


func load_gradients() -> void:
	for grad in gradients:
		var id = %PopupMenu.item_count

		var grad_texture = GradientTexture2D.new()
		grad_texture.gradient = grad
		grad_texture.width = GRADIENT_SIZE_IN_MENU.x
		grad_texture.height = GRADIENT_SIZE_IN_MENU.y

		var label = gradients_names[id - 1] # I subtract one because the element 0 is the title
		%PopupMenu.add_icon_item(grad_texture, "  " + label, id)


func _on_gradient_menu_button_toggled(toggled_on: bool) -> void:
	%PopupMenu.visible = toggled_on


func _on_popup_menu_index_pressed(index: int) -> void:
	%gradient_menu_button.button_pressed = false
	update_gradient(index - 1) # I subtract one because the element 0 is the title


func update_gradient(index: int)-> void:
	SierpinskiConfig.grad = gradients[index]
	%GradientSelector.set_gradient(SierpinskiConfig.grad)
