extends Node2D

signal new_beacon(beacon: Beacon)

@export var beacon_number: int = 0
@export var triangle_number: int = 0
@export var area_mapped: float = 0.0

@export var beacon_asset_path: String
@export var triangle_asset_path: String
var beacon_resource: Resource
var triangle_resource: Resource

var beacons: Dictionary[int, Beacon] = {}
var triangles: Dictionary[int, Triangle] = {}


func _ready() -> void:
	beacon_resource = load(beacon_asset_path)
	triangle_resource = load(triangle_asset_path)
	update_label()


func _on_new_beacon_request() -> void:
	var beacon = beacon_resource.instantiate()
	beacon.id = beacon_number
	beacons[beacon.id] = beacon
	new_beacon.emit(beacon)
	beacon_number += 1
	update_label()


func _on_triangle_request(beacon: Beacon, beacons: Array[Beacon]):
	beacons.sort_custom(
		func(a,b):
			return (
						beacon.position.angle_to_point(a.position) <=
						beacon.position.angle_to_point(b.position)
					)
	)
	for i in range(beacons.size() - 1):
		create_triangle([beacon, beacons[i], beacons[i+1]])

func create_triangle(beacons: Array[Beacon]):
	var triangle = triangle_resource.instantiate()
	triangle.vertices = beacons
	triangle.id = triangle_number
	triangle.init()
	triangles[triangle.id] = triangle
	get_tree().current_scene.add_child(triangle)	
	triangle_number += 1


func update_label():
	$Label.text = "Beacons Placed: " + str(beacon_number)
