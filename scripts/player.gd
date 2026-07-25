extends Area2D

signal new_beacon_request
signal player_died

@export var base_speed: int = 400
@export var speed: int
var forest_speed = base_speed / 2
var mountain_speed = base_speed / 4

var zoom_speed: float = 2.0
var norm_zoom: float = 1
var min_zoom: float = 0.5
var max_zoom: float = 2.0
var target_zoom: float = norm_zoom

@export var life_time_sec: int = 100
@export var time_left_sec: int

var screen_size
var size: Vector2

var touching_forest_tiles: Array = []
var touching_mountain_tiles: Array = []

var new_player: bool = true
var player_dead: bool = false
var time_start: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = $CollisionShape2D.shape.get_rect().size
	speed = base_speed
	time_left_sec = life_time_sec
	$AnimatedSprite2D.play()


func process_life_timer(delta: float) -> void:
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


func process_placement(delta: float) -> void:
	if player_dead:
		return
	if Input.is_action_just_pressed("place_beacon"):
		new_beacon_request.emit()


func _process(delta: float) -> void:
	#if (Input.is_action_just_released("move_down") or
		#Input.is_action_just_released("move_up") or
		#Input.is_action_just_released("move_left") or
		#Input.is_action_just_released("move_right")):
			#print(new_player, " ", time_start," ", time_left_sec)
	process_life_timer(delta)
	process_movement(delta)
	process_placement(delta)
	$Camera2D.zoom = $Camera2D.zoom.lerp(target_zoom * Vector2(1, 1), zoom_speed * delta)


func player_death():
	player_dead = true
	$AnimatedSprite2D.animation = "die" + $AnimatedSprite2D.animation.erase(0, 4)
	$AnimatedSprite2D.animation_finished.connect(_on_death_animation_finished, CONNECT_ONE_SHOT)


func _on_death_animation_finished() -> void:
	player_died.emit()


func _on_terrain_terrain_limits(top_left: Vector2, bottom_right: Vector2) -> void:
	screen_size = bottom_right
	$Camera2D.limit_bottom = bottom_right.y
	$Camera2D.limit_right = bottom_right.x
	$Camera2D.limit_left = top_left.x
	$Camera2D.limit_top = top_left.y



func _on_new_beacon(beacon: Beacon) -> void:
	beacon.position = position
	get_parent().add_child(beacon)


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		var col_layer = PhysicsServer2D.body_get_collision_layer(body_rid)
		if col_layer == 1:
			touching_mountain_tiles.append(body_rid)
			in_mountains()
		elif col_layer == 8:
			touching_forest_tiles.append(body_rid)
			in_forest()
		else:
			pass
		if not touching_mountain_tiles.is_empty():
			in_mountains()
		elif not touching_forest_tiles.is_empty():
			in_forest()
	

func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		var col_layer = PhysicsServer2D.body_get_collision_layer(body_rid)
		if col_layer == 1:
			touching_mountain_tiles.erase(body_rid)
		elif col_layer == 8:
			touching_forest_tiles.erase(body_rid)
		if touching_mountain_tiles.is_empty() and touching_forest_tiles.is_empty():
			speed = base_speed
			target_zoom = norm_zoom
		elif not touching_mountain_tiles.is_empty():
			in_mountains()
		elif touching_mountain_tiles.is_empty() and not touching_forest_tiles.is_empty():
			in_forest()
		else:
			pass

func in_forest():
	speed = forest_speed
	target_zoom = max_zoom

func in_mountains():
	speed = mountain_speed
	target_zoom = min_zoom
