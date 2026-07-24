extends Node2D

signal terrain_limits(top_left: Vector2, bottom_right: Vector2)

var rng = RandomNumberGenerator.new()

@export var noise = FastNoiseLite.new()
@export var width: int = 30
@export var height: int = 30
@export var noise_scale: float = 0.1 
@export var water_height: float = -0.1
@export var plains_height: float = 0
@export var hill_height: float = 0.1

@export var terrain: TileMapLayer 

func _ready() -> void:
	create_terrain()
	emit_limit()

func generate_seed():
	noise.seed = rng.randi()

func create_terrain():
	generate_seed()
	terrain.clear()
	for x in range(width):
		for y in range(height):
			var n2d = noise.get_noise_2d(x * noise_scale, y * noise_scale)
			if n2d < water_height:
				terrain.set_cell(Vector2i(x,y), 2, Vector2i(8, 11))
			elif n2d < plains_height and n2d >= water_height:
				terrain.set_cell(Vector2i(x,y), 2, Vector2i(1, 1))
			else:
				terrain.set_cell(Vector2i(x,y), 2, Vector2i(0, 5))
				
			terrain.get_cell_tile_data(Vector2i(x,y)).set_custom_data("height", n2d)
			
func emit_limit():
	var rect = terrain.get_used_rect()
	var cell_size = terrain.tile_set.tile_size
	var top_left: Vector2 = terrain.to_global(rect.position * cell_size)
	var bottom_right: Vector2 = terrain.to_global(rect.end * cell_size)
	print(top_left)
	print(bottom_right)
	terrain_limits.emit(top_left, bottom_right)
