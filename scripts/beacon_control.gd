extends Node2D

signal new_beacon(beacon: Beacon)

@export var beacon_number: int = 0
@export var beacon_asset_path: String
var beacon_resource: Resource

var beacons: Dictionary[int, Beacon] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	beacon_resource = load(beacon_asset_path)


func _on_new_beacon_request() -> void:
	var beacon = beacon_resource.instantiate()
	beacon.id = beacon_number
	beacons[beacon.id] = beacon
	get_parent().add_child(beacon)
	new_beacon.emit(beacon)
	beacon_number += 1
