extends Control

var args: Dictionary = {}

func _process(delta: float) -> void:
	$CenterContainer.find_child("Map size value").text = str(settings.map_height)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("")
	
func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("")
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_map_size_value_changed(value: int) -> void:
	settings.map_height = value
	settings.map_width = value
