extends CharacterBody2D

signal new_beacon_request
signal triangles_request(beacon: Beacon, beacons: Array[Beacon])
signal player_died

@export var life_time_sec: int = 100
@export var base_speed: int = 400
@export_range(0.1, 1.0, 0.1) var forest_speed_modifier : float = 0.5
@export_range(0.1, 1.0, 0.1) var mountain_speed_modifier : float = 0.25
@export_range(0.1, 2.0, 0.1) var line_of_sight_modifier: float = 1.0
@export_range(0.1, 2.0, 0.1) var forest_zoom: float = 1.5
@export_range(0.1, 2.0, 0.1) var mountain_zoom: float = 0.5

var speed: int

var zoom_speed: float = 2.0
var target_zoom: float = line_of_sight_modifier


@export var time_left_sec: int

var screen_size
var size: Vector2


var touching_forest_tiles: Array = []
var touching_mountain_tiles: Array = []

var beacons_on_screen: Array[Beacon] = []
var valid_beacons: Array[Beacon] = []
var visualize_triangles: bool = false;


var new_player: bool = true
var player_dead: bool = false
var time_start: int

func _ready() -> void:
	size = $CollisionShape2D.shape.get_rect().size
	speed = base_speed
	time_left_sec = life_time_sec
	$AnimatedSprite2D.play()
	z_as_relative = false
	z_index = 5
	
	$AudioStreamPlayer.stream = ResourceLoader.load("res://assets/sound/digital_footstep_grass_3.wav")


func _physics_process(_delta):
	move_and_slide() 


func process_life_timer(_delta: float) -> void:
	if player_dead:
		return
	if new_player and Input.is_anything_pressed():
		new_player = false
		time_start = Time.get_ticks_msec()
	elif not new_player:
		var ellapsed: int = (Time.get_ticks_msec() - time_start) / 1000
		time_left_sec = life_time_sec - ellapsed
		if time_left_sec <= 0:
			player_death()


func process_movement(delta: float) -> void:
	if player_dead:
		return
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO + size, screen_size - size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk_side"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y > 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.animation = "walk_front"
	elif velocity.y < 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.animation = "walk_back"
	else:
		$AnimatedSprite2D.animation = "idle" + $AnimatedSprite2D.animation.erase(0, 4)


func process_placement(_delta: float) -> void:
	if player_dead:
		return
	if ( Input.is_action_just_pressed("place_beacon") or
		 Input.is_action_pressed("place_beacon")):
		visualize_triangles = true
		find_beacons()
		$PlaceBeacon.play()
	elif Input.is_action_just_released("place_beacon"):
		visualize_triangles = false;
		new_beacon_request.emit()

func play_sound() -> void:
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()

func _process(delta: float) -> void:
	#if (Input.is_action_just_released("move_down") or
		#Input.is_action_just_released("move_up") or
		#Input.is_action_just_released("move_left") or
		#Input.is_action_just_released("move_right")):
			#print("P_p|Valid Beacons: ", valid_beacons)
	process_life_timer(delta)
	process_movement(delta)
	process_placement(delta)
	queue_redraw()
	play_sound()
	$Camera2D.zoom = $Camera2D.zoom.lerp(target_zoom * Vector2(1, 1), zoom_speed * delta)


func _draw() -> void:
	if visualize_triangles:
		for beacon in valid_beacons:
			draw_line(Vector2.ZERO, to_local(beacon.global_position), Color.VIOLET)


func player_death():
	player_dead = true
	$AnimatedSprite2D.animation = "die" + $AnimatedSprite2D.animation.erase(0, 4)
	$AnimatedSprite2D.animation_finished.connect(_on_death_animation_finished, CONNECT_ONE_SHOT)


func find_beacons():
	valid_beacons.clear()
	if beacons_on_screen.size() < 2:
		return
	for beacon in beacons_on_screen:
		$BeaconCast.target_position = $BeaconCast.to_local(beacon.global_position)
		$BeaconCast.force_raycast_update()
		if $BeaconCast.is_colliding():
			var collision_point: Vector2 = $BeaconCast.get_collision_point()
			if collision_point.distance_to(beacon.global_position) < 1:
				valid_beacons.append(beacon)
		else:
			valid_beacons.append(beacon)


func _on_death_animation_finished() -> void:
	player_died.emit()


func _on_terrain_terrain_limits(top_left: Vector2, bottom_right: Vector2) -> void:
	screen_size = bottom_right
	$Camera2D.limit_bottom = bottom_right.y
	$Camera2D.limit_right = bottom_right.x
	$Camera2D.limit_left = top_left.x
	$Camera2D.limit_top = top_left.y
	position = (top_left + bottom_right) / 2


func _on_new_beacon(beacon: Beacon) -> void:
	beacon.position = position
	get_parent().add_child(beacon)
	if not touching_mountain_tiles.is_empty():
		beacon.set_z(4)
	elif not touching_forest_tiles.is_empty():
		beacon.set_z(1)
	var notifier: VisibleOnScreenNotifier2D = beacon.get_node("VisibleOnScreenNotifier2D")
	notifier.screen_entered.connect(_on_beacon_entered.bind(beacon))
	notifier.screen_exited.connect(_on_beacon_exited.bind(beacon))
	if valid_beacons.size() >= 2:
		triangles_request.emit(beacon, valid_beacons)

func _on_beacon_entered(beacon: Beacon):
	beacons_on_screen.append(beacon)


func _on_beacon_exited(beacon: Beacon):
	beacons_on_screen.remove_at(beacons_on_screen.find(beacon))


func in_forest():
	speed = base_speed * forest_speed_modifier
	target_zoom = line_of_sight_modifier * forest_zoom
	$AudioStreamPlayer.stream = ResourceLoader.load("res://assets/sound/digital_footstep_snow_1.wav")

func in_mountains():
	speed = base_speed * mountain_speed_modifier
	target_zoom = line_of_sight_modifier * mountain_zoom
	$AudioStreamPlayer.stream = ResourceLoader.load("res://assets/sound/digital_footstep_gravel_3.wav")

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		var col_layer = PhysicsServer2D.body_get_collision_layer(body_rid)
		if col_layer == 1:
			touching_mountain_tiles.append(body_rid)
		elif col_layer == 4:
			print("Entered town.")
		elif col_layer == 8:
			touching_forest_tiles.append(body_rid)
		if not touching_mountain_tiles.is_empty():
			in_mountains()
		elif not touching_forest_tiles.is_empty():
			in_forest()


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		var col_layer = PhysicsServer2D.body_get_collision_layer(body_rid)
		if col_layer == 1:
			touching_mountain_tiles.erase(body_rid)
		elif col_layer == 8:
			touching_forest_tiles.erase(body_rid)
		if touching_mountain_tiles.is_empty() and touching_forest_tiles.is_empty():
			speed = base_speed
			target_zoom = line_of_sight_modifier
			$AudioStreamPlayer.stream = ResourceLoader.load("res://assets/sound/digital_footstep_grass_3.wav")
		elif not touching_mountain_tiles.is_empty():
			in_mountains()
		elif touching_mountain_tiles.is_empty() and not touching_forest_tiles.is_empty():
			in_forest()
