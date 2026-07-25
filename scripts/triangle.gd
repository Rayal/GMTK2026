class_name Triangle extends Area2D

@export var id: int
@export var vertices: Array[Beacon]
@export var area: int

@export var colour: Color = Color.DARK_ORCHID
@export_range(0.0, 1.0) var fill_alpha: float = 0.35

var vertices2D: PackedVector2Array = []

const MARBLE_SHADER: Shader = preload("res://shaders/triangle_marble.gdshader")
static var marble_material: ShaderMaterial

func init() -> void:
	for vertex: Beacon in vertices:
		vertices2D.append(vertex.global_position)
	$CollisionPolygon2D.polygon = vertices2D
	$Polygon2D.polygon = vertices2D
	$Polygon2D.material = _get_marble_material()
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


static func _get_marble_material() -> ShaderMaterial:
	if marble_material == null:
		var noise := FastNoiseLite.new()
		noise.frequency = 0.03

		var noise_texture := NoiseTexture2D.new()
		noise_texture.seamless = true
		noise_texture.width = 256
		noise_texture.height = 256
		noise_texture.noise = noise

		var material := ShaderMaterial.new()
		material.shader = MARBLE_SHADER
		material.set_shader_parameter("noise_tex", noise_texture)
		marble_material = material
	return marble_material
