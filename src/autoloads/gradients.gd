extends Node


signal gradients_ready

# To make gradients work in all platforms (including HTML), you can asign the gradients via an @export, thats what the other gradients.gd script does
# This script is for storing them so any other scrip can access the gradients
var gradients : Array[Gradient] = []
var gradients_names : Array[String] = []

var grad_ready = false

func _process(_delta: float) -> void:
    if !grad_ready && gradients != []:
        emit_signal("gradients_ready")
