extends Node2D

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		$CanvasLayer/Menu.visible = !$CanvasLayer/Menu.visible
