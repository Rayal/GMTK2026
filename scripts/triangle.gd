class_name Triangle extends Area2D

@export var id: int
@export var vertices: Array[Beacon]
@export var area: float

var vertices2D: PackedVector2Array = []

func init() -> void:
	for vertex: Beacon in vertices:
		vertices2D.append(vertex.global_position)
	$CollisionPolygon2D.polygon = vertices2D
	

func _draw() -> void:
	draw_colored_polygon(vertices2D, Color.DARK_ORCHID)
