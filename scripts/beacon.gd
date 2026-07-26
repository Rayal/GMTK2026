class_name Beacon extends Area2D

@export var id : int
@export var triangles: Array[int]

func _ready() -> void:
	z_as_relative = false
	z_index = 3
