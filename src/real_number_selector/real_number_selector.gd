extends PanelContainer

@export var variable_name = "a"
@export var integer = false
var alt_integer = false
var prev_alt_integer = false
@export var LERP_VALUE = 15.0
@export var sensitivity = 0.004
@export var fine_control1 = 0.1
@export var fine_control2 = 0.001

@export var exp_edit := false

@export var decimal_places := 5

@export var curr_value: float = 0.35
@export var divide_by_a_thouand = false
@export var minimun_inclusive = true
var initial_value := 0.0
var target_value := 0.0

var dragging = false

var last_click_time = 0
var double_click_threshold_ms = 250

@export var exp_maximum = 10000000


func _ready() -> void:
	var val = (curr_value / 1000.) if divide_by_a_thouand else curr_value
	
	$HSlider.exp_edit = exp_edit
	$HSlider.value = val
	target_value = val
	update_label_value()

	initial_value = val


func _process(delta: float) -> void:
	var mouse_in = $HSlider.get_global_rect().has_point(get_global_mouse_position())
	$hover.visible = dragging or mouse_in

	alt_integer = Input.is_action_pressed("integer") and dragging

	if prev_alt_integer != alt_integer:
		target_value = roundi(target_value)
		$HSlider.value = roundi(target_value)

	if integer:
		curr_value = roundi(target_value)
	else:
		if alt_integer:
			curr_value = lerp(curr_value, roundf(target_value), LERP_VALUE * delta)
		else:
			curr_value = lerp(curr_value, target_value, LERP_VALUE * delta)

	var h_slider_min = $HSlider.min_value
	var h_slider_max = $HSlider.max_value
	if $HSlider.allow_greater:
		h_slider_max = INF
	if $HSlider.allow_lesser:
		h_slider_min = -INF

	var minimun = h_slider_min if minimun_inclusive else (h_slider_min + pow(10.0, -decimal_places))
	curr_value = clamp(curr_value, minimun, exp_maximum if exp_edit else h_slider_max)
	target_value = clamp(target_value, minimun, exp_maximum if exp_edit else h_slider_max)

	if integer:
		curr_value = roundi(curr_value)

	update_label_value()
	
	prev_alt_integer = alt_integer

func _input(event: InputEvent) -> void:
	if $disabled.visible:
		return

	if event is InputEventMouseMotion and dragging:
		var shift = Input.is_key_pressed(KEY_SHIFT)
		var ctrl = Input.is_key_pressed(KEY_CTRL)

		var curr_sensitivity = sensitivity
		if shift:
			curr_sensitivity *= fine_control1
		if ctrl:
			curr_sensitivity *= fine_control2

		if exp_edit:
			var log_min = to_log_space($HSlider.min_value)
			var log_max = to_log_space($HSlider.max_value)
			var log_val = to_log_space(target_value)
			log_val += event.relative.x * curr_sensitivity * (log_max - log_min)
			target_value = from_log_space(log_val)
		else:
			target_value += event.relative.x * curr_sensitivity * ($HSlider.max_value - $HSlider.min_value)

		if integer or alt_integer:
			$HSlider.value = roundi(target_value)
		else:
			$HSlider.value = target_value

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if $HSlider.get_global_rect().has_point(event.position):
			dragging = event.pressed

			if !event.pressed:
				return

			if (Time.get_ticks_msec() - last_click_time) < double_click_threshold_ms:
				target_value = initial_value 

			last_click_time = Time.get_ticks_msec()
			$HSlider.value = target_value

		else:
			dragging = false


func get_value() -> float:
	return curr_value
	

func get_target_value() -> float:
	return target_value


func set_value(value: float) -> void:
	target_value = value
	$HSlider.value = target_value
	
	
func set_variable_name(new_name: String) -> void:
	variable_name = new_name
	update_label_value()



func _on_h_slider_value_changed(_value: float) -> void:
	update_label_value()


func update_label_value() -> void:
	if integer or alt_integer:
		$HSlider/Label.text = variable_name + " = " + str(roundi(target_value))
	else:
		$HSlider/Label.text = variable_name + " = " + ("%.*f" % [decimal_places, target_value])


func set_disabled(disabled: bool) -> void:
	$disabled.visible = disabled


func to_log_space(v: float) -> float:
	return log(max(v, 1e-9))

func from_log_space(v: float) -> float:
	return exp(v)
