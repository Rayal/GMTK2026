extends Area2D

@export var base_speed: int = 400
@export var speed: int
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	speed = base_speed
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	position = position.clamp(Vector2.ZERO, screen_size)
	
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
