extends Control

@export var default_grad_index = 0

@export var gradients : Array[Gradient]
@export var gradients_names : Array[String]

var GRADIENT_SIZE_IN_MENU = Vector2(181, 22)


func _ready() -> void:
	load_gradients()
	update_gradient(default_grad_index) 



func _process(delta: float) -> void:
	MandelbulbConfig.hit_position_strength = %hit_position.get_value()
	MandelbulbConfig.iteratios_coloring_strength = %iteratios_coloring_strength.get_value()
	MandelbulbConfig.lighting_strength = %lighting.get_value()
	MandelbulbConfig.ambient_light = %ambient_light.get_value()
	MandelbulbConfig.gradient = %GradientSelector.grad

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



func _on_gradient_menu_button_toggled(toggled_on: bool) -> void:
	%PopupMenu.visible = toggled_on


func _on_popup_menu_index_pressed(index: int) -> void:
	%gradient_menu_button.button_pressed = false
	update_gradient(index - 1) # I subtract one because the element 0 is the title


func update_gradient(index: int)-> void:
	MandelbrotConfig.grad = gradients[index]
	%GradientSelector.set_gradient(MandelbrotConfig.grad)
