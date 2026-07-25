extends Node2D

signal new_beacon(beacon: Beacon)

@export var beacon_number: int = 0
@export var triangle_number: int = 0
@export var area_mapped: int = 0

@export var beacon_asset_path: String
@export var triangle_asset_path: String
var beacon_resource: Resource
var triangle_resource: Resource

var beacons: Dictionary[int, Beacon] = {}
var triangles: Dictionary[int, Triangle] = {}


func _ready() -> void:
	beacon_resource = load(beacon_asset_path)
	triangle_resource = load(triangle_asset_path)
	update_labels()


func _on_new_beacon_request() -> void:
	var beacon = beacon_resource.instantiate()
	beacon.id = beacon_number
	beacons[beacon.id] = beacon
	new_beacon.emit(beacon)
	beacon_number += 1
	update_labels()


func _on_triangle_request(beacon: Beacon, beacons: Array[Beacon]):
	if beacons.size() == 2:
		beacons.append(beacon)
		create_triangle(beacons)
		return

	beacons.sort_custom(
		func(a, b):
			return (
						beacon.global_position.angle_to_point(a.global_position) <=
						beacon.global_position.angle_to_point(b.global_position)
					)
	)

	var n: int = beacons.size()
	var raw_angles: Array[float] = []
	for b in beacons:
		raw_angles.append(beacon.global_position.angle_to_point(b.global_position))

	var gaps: Array[float] = []
	for i in range(n - 1):
		gaps.append(raw_angles[i + 1] - raw_angles[i])
	gaps.append(TAU - (raw_angles[n - 1] - raw_angles[0]))

	var max_gap_index: int = 0
	for i in range(1, n):
		if gaps[i] > gaps[max_gap_index]:
			max_gap_index = i

	var ordered: Array[Beacon] = []
	for i in range(n):
		ordered.append(beacons[(max_gap_index + 1 + i) % n])

	for i in range(n - 1):
		create_triangle([beacon, ordered[i], ordered[i + 1]])


func create_triangle(beacons: Array[Beacon]):
	var triangle = triangle_resource.instantiate()
	triangle.vertices = beacons
	triangle.id = triangle_number
	triangle.init()
	area_mapped += triangle.area
	triangles[triangle.id] = triangle
	get_tree().current_scene.add_child(triangle)	
	triangle_number += 1


func update_labels():
	$BeaconLabel.text = "Beacons Placed: " + str(beacon_number)
	$TriangleLabel.text = "\nArea Mapped: " + str(area_mapped)
