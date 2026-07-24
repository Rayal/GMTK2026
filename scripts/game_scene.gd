extends Node2D

@onready var death_dialog: ConfirmationDialog = $DeathDialog


func _on_player_player_died() -> void:
	get_tree().paused = true
	death_dialog.popup_centered()


func _on_death_dialog_confirmed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_death_dialog_canceled() -> void:
	get_tree().quit()
