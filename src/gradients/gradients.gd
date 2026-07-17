extends Node

# To make gradients work in all platforms (including HTML), you can asign the gradients via an @export, thats this script does
# The other gradients.gd script allows every other script to access the gradients
@export var gradients : Array[Gradient]
@export var gradients_names : Array[String]


func _ready() -> void:
	Gradients.gradients = gradients
	Gradients.gradients_names = gradients_names
