extends HBoxContainer

@export var integer = false

var curr_value = -1
@export var tween_duration = 0.05

func _ready() -> void:
	$value_label.text = str(int($slider.value)) if integer else "%.3f" % $slider.value
	curr_value = $slider.value

func _on_slider_value_changed(value: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "curr_value", value, tween_duration)
	$value_label.text = str(int($slider.value)) if integer else "%.3f" % $slider.value

func get_value():
	return int(curr_value) if integer else curr_value
