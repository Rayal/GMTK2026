extends Node2D

signal upgrade_choice(choice: int)

@onready var death_dialog: ConfirmationDialog = $DeathDialog
@onready var settlement_dialog: AcceptDialog = $SettlementDialog
@onready var stale_settlement_dialog: AcceptDialog = $SettlementDialog2

func _ready() -> void:
	settlement_dialog.get_ok_button().hide()


func _on_player_player_died() -> void:
	get_tree().paused = true
	death_dialog.popup_centered()


func _on_death_dialog_confirmed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_death_dialog_canceled() -> void:
	get_tree().quit()


func _on_player_settlement_entered() -> void:
	get_tree().paused = true
	if $Timer.is_stopped():
		settlement_dialog.popup_centered()
	else:
		stale_settlement_dialog.popup_centered()


func _on_settlement_choice_pressed(choice: int) -> void:
	get_tree().paused = false
	$Timer.start(30)
	settlement_dialog.hide()
	print("Settlement choice selected: ", choice)
	upgrade_choice.emit(choice)


func _on_settlement_dialog_closed() -> void:
	get_tree().paused = false
