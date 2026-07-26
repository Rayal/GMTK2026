extends Control

@export var game_scene: String

var preloaded_game_scene: PackedScene


func _ready() -> void:
	ResourceLoader.load_threaded_request(game_scene)


func _process(_delta: float) -> void:
	if preloaded_game_scene:
		set_process(false)
		return
	if ResourceLoader.load_threaded_get_status(game_scene) == ResourceLoader.THREAD_LOAD_LOADED:
		preloaded_game_scene = ResourceLoader.load_threaded_get(game_scene)
		set_process(false)


func _on_start_button_pressed() -> void:
	if preloaded_game_scene:
		get_tree().change_scene_to_packed(preloaded_game_scene)
	else:
		get_tree().change_scene_to_file(game_scene)

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")

func _on_about_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/about.tscn")
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
