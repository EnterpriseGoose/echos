extends Node

enum VIEW {FLAME, ECHO, FORCE, FLY}
var player_view: VIEW = VIEW.FLAME:
	set(view):
		player_view = view
		player_view_changed.emit(view)

enum GAME_STATE {PLAYING, WIN, LOSE}
var game_state: GAME_STATE = GAME_STATE.PLAYING

var views_unlocked = [VIEW.FLAME]
@export var player: Player

signal player_view_changed(view: VIEW)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_lantern") and not dying:
		player_view = views_unlocked[(views_unlocked.find(player_view) + 1) % len(views_unlocked)]
		player_view_changed.emit(player_view)
		print(player_view)

var dying = false
