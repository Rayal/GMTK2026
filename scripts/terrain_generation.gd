extends Node2D

signal terrain_limits(top_left: Vector2, bottom_right: Vector2)

var rng = RandomNumberGenerator.new()

@export var noise = FastNoiseLite.new()
@export var width: int = 50
@export var height: int = 50
@export var noise_scale: float = 0.1 
@export var forest_threshold: float = -0.1

@export var terrain: TileMapLayer
@export var terrain_objects: TileMapLayer

func _ready() -> void:
	create_base_terrain()
	emit_limit()
	create_objects_on_terrain()


func generate_seed():
	noise.seed = rng.randi()

func create_base_terrain():
	generate_seed()
	terrain.clear()
	for x in range(width):
		for y in range(height):
			var n2d = noise.get_noise_2d(x * noise_scale, y * noise_scale)
			terrain.set_cell(Vector2i(x,y), 0, Vector2i(0, 0))
			if n2d < forest_threshold:
				terrain_objects.set_cell(Vector2i(x,y), 0, Vector2i(8, 7))


func emit_limit():
	var rect = terrain.get_used_rect()
	var cell_size = terrain.tile_set.tile_size
	var top_left: Vector2 = terrain.to_global(rect.position * cell_size)
	var bottom_right: Vector2 = terrain.to_global(rect.end * cell_size)
	print(top_left)
	print(bottom_right)
	terrain_limits.emit(top_left, bottom_right)



func create_objects_on_terrain():
	
	for i in range(5):
		var terrain_feature = terrain_objects.get_children().pick_random()
		terrain_feature.visible = true
		terrain_feature.rotate(deg_to_rad(90))
		terrain_feature.position.x = randi() % width * 10
		terrain_feature.position.y = randi() % height * 10
