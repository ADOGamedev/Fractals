extends Node2D

func _process(_delta: float) -> void:
	$SierpinskiTriangle.zoom = $Camera2D.zoom.x
