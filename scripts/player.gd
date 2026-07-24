extends Area2D

signal new_beacon_request
signal player_died

@export var base_speed: int = 400
@export var speed: int

@export var life_time_sec: int = 100
@export var time_left_sec: int

var screen_size
var size: Vector2


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


func player_death():
	$AnimatedSprite2D.animation = "die" + $AnimatedSprite2D.animation.erase(0, 4)
	player_dead = true
	player_died.emit()
	print("Player died!")


func _on_terrain_terrain_limits(top_left: Vector2, bottom_right: Vector2) -> void:
	screen_size = bottom_right
	$Camera2D.limit_bottom = bottom_right.y
	$Camera2D.limit_right = bottom_right.x
	$Camera2D.limit_left = top_left.x
	$Camera2D.limit_top = top_left.y



func _on_new_beacon(beacon: Beacon) -> void:
	beacon.position = position
	get_parent().add_child(beacon)
