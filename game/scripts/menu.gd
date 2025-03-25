extends Control

@export var level1: Level1

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	$Control/HangingLantern.light_level = 0
	while $Control/HangingLantern.lantern.light_range > 0:
		await get_tree().create_timer(.1).timeout
	visible = false
	level1.level_state = 1

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	$Control/HangingLantern.light_level = 8
