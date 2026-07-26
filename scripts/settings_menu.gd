extends Control

var args: Dictionary = {}

func _process(delta: float) -> void:
	$CenterContainer.find_child("Map size value").text = str(settings.map_height)
	$CenterContainer.find_child("Tree count value").text = str(abs(settings.forest_threshold) * 100 - 5)
	$CenterContainer.find_child("Hill propability value").text = str(settings.hill_generation_probability)
	$CenterContainer.find_child("Lake propability value").text = str(settings.lake_generation_probability)
	$CenterContainer.find_child("Settelment propability value").text = str(settings.settelment_generation_probability)
	

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_map_size_value_changed(value: int) -> void:
	settings.map_height = value
	settings.map_width = value


func _on_tree_count_value_changed(value: float) -> void:
	settings.forest_threshold = (value + 5) / -100


func _on_hills_value_changed(value: float) -> void:
	settings.hill_generation_probability = value


func _on_lakes_value_changed(value: float) -> void:
	settings.lake_generation_probability = value


func _on_settelment_value_changed(value: float) -> void:
	settings.settelment_generation_probability = value
