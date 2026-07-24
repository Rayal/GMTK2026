extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_label()

func update_label():
	$Label.text = "Time left: " + str(get_parent().get_parent().find_child("Player").time_left_sec)
