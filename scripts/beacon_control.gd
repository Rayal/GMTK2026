extends Node2D

signal new_beacon(beacon: Beacon)

@export var beacon_number: int = 0
@export var beacon_asset_path: String
var beacon_resource: Resource

var beacons: Dictionary[int, Beacon] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	beacon_resource = load(beacon_asset_path)
	update_label()

func _on_new_beacon_request() -> void:
	var beacon = beacon_resource.instantiate()
	beacon.id = beacon_number
	beacons[beacon.id] = beacon
	new_beacon.emit(beacon)
	beacon_number += 1
	update_label()

func update_label():
	$Label.text = "Beacons Placed: " + str(beacon_number)
