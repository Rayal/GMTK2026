extends Node2D

signal terrain_limits(top_left: Vector2, bottom_right: Vector2)

var rng = RandomNumberGenerator.new()

@export var noise = FastNoiseLite.new()
@export var map_width: int = 50
@export var map_height: int = 50
@export var noise_scale: float = 0.1 
@export var forest_threshold: float = -0.1

@export var terrain: TileMapLayer
@export var terrain_objects: TileMapLayer

@export var max_object_size = 4
@export var object_count = 10
@export var min_object_distance := 10.0
@export var hill_generation_probability: = 1
@export var lake_generation_probability: = 0.5
@export var settelment_generation_probability: = 0.1

func _ready() -> void:
	create_base_terrain()
	emit_limit()
	create_objects_on_terrain()


func generate_seed():
	noise.seed = 45 #rng.randi()

func create_base_terrain():
	generate_seed()
	terrain.clear()
	for x in range(map_width):
		for y in range(map_height):
			var n2d = noise.get_noise_2d(x * noise_scale, y * noise_scale)
			terrain.set_cell(Vector2i(x,y), 0, Vector2i(0, 0))
			if n2d < forest_threshold:
				terrain_objects.set_cell(Vector2i(x,y), 0, Vector2i(8, 7))


func emit_limit():
	var rect = terrain.get_used_rect()
	var tile_size = terrain.tile_set.tile_size
	var top_left: Vector2 = terrain.to_global(rect.position * tile_size)
	var bottom_right: Vector2 = terrain.to_global(rect.end * tile_size)
	terrain_limits.emit(top_left, bottom_right)



func create_objects_on_terrain():
	var probability_sum = hill_generation_probability + lake_generation_probability + settelment_generation_probability
	var object_locations = generate_map_object_locations()
	print(object_locations)
	for object_location in object_locations:
		var rnd = randf_range(0, probability_sum)
		if rnd <= hill_generation_probability:
			add_terrain_element("hills", object_location)
		elif rnd > hill_generation_probability and rnd <= hill_generation_probability + lake_generation_probability:
			add_terrain_element("lakes", object_location)
		else:
			add_terrain_element("settelments", object_location)

func generate_map_object_locations() -> Array[Vector2i]:
	var object_locations: Array[Vector2i] = []
	var attempts := 0
	while object_locations.size() < object_count and attempts < 1000:
		var sample := Vector2i(
			randi_range(max_object_size, map_width - max_object_size),
			randi_range(max_object_size, map_height - max_object_size)
		)

		var valid := true
		for object in object_locations:
			if sample.distance_to(object) < min_object_distance:
				valid = false
				break
				
		if valid:
			object_locations.append(sample)
		attempts += 1
	return object_locations


func add_terrain_element(terrain_element: String, pos_vector: Vector2i):
		var element_scenes: Array[PackedScene] = load_scenes_from_folder("res://assets/terrain/" + terrain_element + "/")
		element_scenes.shuffle()
		var element = element_scenes.pop_front().instantiate()
		#element.rotate(deg_to_rad(randi_range(0,3) * 90))
		var tile_size: Vector2= terrain.tile_set.tile_size / 2
		element.set_global_position(terrain.map_to_local(pos_vector) - tile_size)
		terrain_objects.add_child(element)


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
