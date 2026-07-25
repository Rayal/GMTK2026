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
var beacons_on_screen: Array[int] = []


func _ready() -> void:
	beacon_resource = load(beacon_asset_path)
	triangle_resource = load(triangle_asset_path)
	update_label()


func _on_new_beacon_request() -> void:
	var beacon = beacon_resource.instantiate()
	beacon.id = beacon_number
	beacons[beacon.id] = beacon
	
	var notifier: VisibleOnScreenNotifier2D = beacon.get_node("VisibleOnScreenNotifier2D")
	notifier.screen_entered.connect(_on_beacon_entered.bind(beacon.id))
	notifier.screen_exited.connect(_on_beacon_exited.bind(beacon.id))
	
	new_beacon.emit(beacon)
	beacon_number += 1
	if beacons_on_screen.size() >= 2:
		create_triangle(beacon)
	update_label()


func _on_beacon_entered(beacon_id: int):
	beacons_on_screen.append(beacon_id)
	print("Beacons on screen: ", beacons_on_screen)


func _on_beacon_exited(beacon_id: int):
	beacons_on_screen.remove_at(beacons_on_screen.find(beacon_id))
	print("Beacons on screen: ", beacons_on_screen)



func create_triangle(beacon: Beacon):
	print("CT|Beacons on screen: ", beacons_on_screen)
	var triangle = triangle_resource.instantiate()
	
	beacons_on_screen.sort_custom(
		func(a, b):
			return (beacons[a].position.distance_to(beacon.position) <= 
					beacons[b].position.distance_to(beacon.position))
	)
	print("CT|Beacons closest: ", beacons_on_screen.slice(0, 2))
	triangle.vertices = beacons_on_screen.slice(0, 2)
	triangle.vertices.append(beacon.id)
	triangle.id = triangle_number
	triangle.init(
		[
			beacons[beacons_on_screen[0]].global_position,
			beacons[beacons_on_screen[1]].global_position,
			beacon.global_position
		]
	)
	triangles[triangle.id] = triangle
	get_tree().current_scene.add_child(triangle)	
	triangle_number += 1


func update_label():
	$Label.text = "Beacons Placed: " + str(beacon_number)
