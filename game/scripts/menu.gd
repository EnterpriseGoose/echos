extends Control

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	visible = false
