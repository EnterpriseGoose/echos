extends Node

enum VIEW {NONE, ECHO, FLY}
var player_view: VIEW = VIEW.NONE:
	set(view):
		player_view = view
		player_view_changed.emit(view)
var player_view_force: bool = false

enum GAME_STATE {PLAYING, WIN, LOSE}
var game_state: GAME_STATE = GAME_STATE.PLAYING

var views_unlocked = [VIEW.NONE, VIEW.ECHO, VIEW.FLY]
@export var player: Player

signal player_view_changed(view: VIEW)
signal player_view_force_changed(mode: bool)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_lantern"):
		player_view = views_unlocked[(views_unlocked.find(player_view) + 1) % len(views_unlocked)]
		player_view_changed.emit(player_view)
		print(player_view)
	if event.is_action_pressed("switch_force_mode"):
		player_view_force = !player_view_force
		player_view_force_changed.emit(player_view_force)
		print("force mode activated" if player_view_force else "fire mode activated")
