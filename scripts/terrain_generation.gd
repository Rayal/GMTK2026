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
	
	for i in range(1): 
		var hill_scenes: Array[PackedScene] = load_scenes_from_folder("res://assets/terrain/hills/")
		hill_scenes.shuffle()
		var hill = hill_scenes.pop_front().instantiate()
		hill.rotate(deg_to_rad(randi_range(0,3) * 90))
		hill.set_global_position(Vector2i(100,100))
		terrain_objects.add_child(hill)
		#terrain_feature.visible = true
		#terrain_feature.rotate(deg_to_rad(180))
		#terrain_feature.position = Vector2i(randi() % width, randi() % height)
		#terrain_feature.set_global_position(Vector2i(100,100))


func load_scenes_from_folder(path: String) -> Array[PackedScene]:
	var loaded_scenes: Array[PackedScene] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "tscn":
				var full_path = path + "/" + file_name
				var scene = ResourceLoader.load(full_path) as PackedScene
				if scene:
					loaded_scenes.append(scene)
				file_name = dir.get_next()
	return loaded_scenes
