extends Node2D

signal beacon_number(beacons: int)

var beacons: Array[Beacon] = []


func add_beacon(new_beacon: Beacon) -> void:
	beacons.append(new_beacon)
	beacon_number.emit(beacons.size())


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
