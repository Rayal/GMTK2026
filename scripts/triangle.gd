class_name Triangle extends Area2D

@export var id: int
@export var vertices: Array[int]
@export var area: float

var vertices2D: PackedVector2Array

func init(beacons: Array) -> void:
	vertices2D = PackedVector2Array(beacons)

func _draw() -> void:
	draw_colored_polygon(vertices2D, Color.DARK_ORCHID)
