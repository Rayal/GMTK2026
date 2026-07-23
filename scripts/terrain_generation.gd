extends Node2D

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

func generate_seed():
	noise.seed = 221307822#rng.randi()
	print(noise.seed)

func x_left_edge(x: int) -> bool:
	return x == 0

func x_right_edge(x: int) -> bool:
	return x == width - 1

func y_top_edge(y: int) -> bool:
	return y == 0

func y_bottom_edge(y: int) -> bool:
	return y == height - 1

func place_water(x: int, y: int) -> void:
	terrain.set_cell(Vector2i(x,y), 2, Vector2i(8, 11))

func place_water_up(x: int, y: int) -> void:
	terrain.set_cell(Vector2i(x,y), 2, Vector2i(8, 12))

func place_water_down(x: int, y: int) -> void:
	terrain.set_cell(Vector2i(x,y), 2, Vector2i(8, 10))
	
func place_water_left(x: int, y: int) -> void:
	terrain.set_cell(Vector2i(x,y), 2, Vector2i(9, 11))

func place_water_right(x: int, y: int) -> void:
	terrain.set_cell(Vector2i(x,y), 2, Vector2i(7, 11))

func place_water_ur(x: int, y: int) -> void:
	terrain.set_cell(Vector2i(x,y), 2, Vector2i(7, 12))

func place_water_ul(x: int, y: int) -> void:
	terrain.set_cell(Vector2i(x,y), 2, Vector2i(9, 12))
	
func place_water_dr(x: int, y: int) -> void:
	terrain.set_cell(Vector2i(x,y), 2, Vector2i(7, 10))

func place_water_dl(x: int, y: int) -> void:
	terrain.set_cell(Vector2i(x,y), 2, Vector2i(9, 10))

func place_plains(x: int, y: int) -> void:
	terrain.set_cell(Vector2i(x,y), 2, Vector2i(1, 1))

func is_water_height(terrain_value: float) -> bool:
	return terrain_value <= water_height

func is_plains_height(terrain_value: float) -> bool:
	return terrain_value <= plains_height and not is_water_height(terrain_value)

func is_hill_height(terrain_value: float) -> bool:
	return terrain_value > plains_height

func check_neighbour(current: float, other: float) -> int:
	if other < current:
		return -1
	if other > current:
		return 1
	return 0


func check_neighbours(x: int, y: int, terrain_array: Array[PackedFloat32Array]) -> Array[int]:
	var retval: Array[int] = [0, 0, 0, 0]
	var current_val: float = terrain_array[x][y]
	var other: float
	if not x_left_edge(x):
		other = terrain_array[x - 1][y]
		retval[3] = check_neighbour(current_val, other)
	if not x_right_edge(x):
		other = terrain_array[x + 1][y]
		retval[1] = check_neighbour(current_val, other)
	if not y_top_edge(y):
		other = terrain_array[x][y - 1]
		retval[0] = check_neighbour(current_val, other)
	if not y_bottom_edge(y):
		other = terrain_array[x][y + 1]
		retval[2] = check_neighbour(current_val, other)
	return retval


func generate_terrain_values() -> Array[PackedFloat32Array]:
	generate_seed()
	var terrain_array: Array[PackedFloat32Array] = []
	for x in range(width):
		var w_array: PackedFloat32Array = PackedFloat32Array()
		for y in range(height):
			var val = noise.get_noise_2d(x * noise_scale, y * noise_scale)
			if is_water_height(val):
				val = water_height
			elif is_hill_height(val):
				val = hill_height
			else:
				val = plains_height
			w_array.append(val)
		terrain_array.append(w_array)
	return terrain_array


func place_terrain_tiles(terrain_array: Array[PackedFloat32Array]) -> void:
	for x in range(width):
		for y in range(height):
			var current_val: float = terrain_array[x][y]
			if is_water_height(current_val):
				place_water(x, y)
			elif is_hill_height(current_val):
				terrain.set_cell(Vector2i(x,y), 2, Vector2i(0, 5)) # place_hill
			else:
				#place_plains(x, y)
				var neighbours: Array[int] = check_neighbours(x, y, terrain_array)
				if neighbours[0] < 0 and neighbours[1] < 0:
					place_water_ur(x, y)
				elif neighbours[2] < 0 and neighbours[1] < 0:
					place_water_dr(x, y)
				elif neighbours[2] < 0 and neighbours[3] < 0:
					place_water_dl(x, y)
				elif neighbours[2] < 0 and neighbours[1] < 0:
					place_water_ul(x, y)
				elif neighbours[0] < 0:
					place_water_up(x, y)
				elif neighbours[1] < 0:
					place_water_right(x, y)
				elif neighbours[2] < 0:
					place_water_down(x, y)
				elif neighbours[3] < 0:
					place_water_left(x, y)
				else:
					place_plains(x, y)
func create_terrain():
	terrain.clear()
	var terrain_values = generate_terrain_values()
	print(terrain_values)
	place_terrain_tiles(terrain_values)
	
	
