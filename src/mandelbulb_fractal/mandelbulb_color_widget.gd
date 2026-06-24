extends Control


func _process(delta: float) -> void:
	MandelbulbConfig.hit_position_strength = %hit_position.get_value()
	MandelbulbConfig.edge_highlight = %edge_highlight.get_value()
	MandelbulbConfig.lighting_strength = %lighting.get_value()
