class_name Triangle extends Area2D

@export var id: int
@export var vertices: Array[Beacon]
@export var area: int

@export var colour: Color = Color.DARK_ORCHID
@export_range(0.0, 1.0) var fill_alpha: float = 0.35

var vertices2D: PackedVector2Array = []

func init() -> void:
	for vertex: Beacon in vertices:
		vertices2D.append(vertex.global_position)
	$CollisionPolygon2D.polygon = vertices2D
	area = (
		0.5 * 
		vertices[0].global_position.distance_to(vertices[1].global_position) *
		vertices[0].global_position.distance_to(vertices[2].global_position) *
		abs(sin(
			vertices[0].global_position.angle_to_point(vertices[1].global_position) - 
			vertices[0].global_position.angle_to_point(vertices[2].global_position)
		)) / (32 * 32 * 5 * 5)
	)

func _draw() -> void:
	draw_line(vertices2D[0], vertices2D[1], colour, 2)
	draw_line(vertices2D[0], vertices2D[2], colour, 2)
	draw_line(vertices2D[2], vertices2D[1], colour, 2)
	
	draw_colored_polygon(vertices2D, Color(colour, fill_alpha))
