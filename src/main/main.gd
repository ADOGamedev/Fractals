extends Node2D

func _process(_delta: float) -> void:
    var zoom = $Camera2D.zoom.x
    $SierpinskiTriangle.iterations = min(17, roundi(log(zoom) / log(2)) + 10)
