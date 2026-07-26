extends Control

@export var game_scene: String

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(game_scene)
	
func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")

func _on_about_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/about.tscn")
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
