extends Node2D
class_name HangingLantern

@export var swing: float = 0
@export var light_level: float = 0:
	set(new_level):
		if not new_level == light_level:
			lantern.fade_light(new_level)
		light_level = new_level
@export var lantern: Lantern
@export var fade: float = 0
@export var max_level = 1

@export var logger: bool = false

@onready var chain_len = ($Chain.chain_end.position - $Chain.chain_start.position).length()
var on = false
var timer = Timer.new()

signal state_changed()

func _ready() -> void:
	lantern.fade_light(light_level)
	if light_level > 0:
		on = true

func _process(delta: float) -> void:
	if light_level > 0 and fade > 0 and not lantern.light_range < lantern.new_light_range:
		light_level -= fade * 0.1 * delta
	if light_level <= 0:
		on = false
		if light_level != 0:
			state_changed.emit()
		light_level = 0
	if logger:
		print(light_level)
	if swing > 0:
		var time = chain_len * swing / 100
		if fmod(Time.get_unix_time_from_system(), time) < time/4:
			push(Vector2.RIGHT * 1, Vector2.ZERO)
		if fmod(Time.get_unix_time_from_system(), time) > time/2 && fmod(Time.get_unix_time_from_system(), time) < 3 * time/4:
			push(Vector2.LEFT * 1, Vector2.ZERO)
		

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Fireball:
		light_level = max_level
		lantern.apply_force(Vector2.RIGHT * Global.player.velocity.x * 10, Vector2(0, 50))
		on = true
		state_changed.emit()
		
func push(force: Vector2, _pos: Vector2):
	#lantern.apply_force(force * $Chain.pin2.position.length() * .01)
		
	for chain in $Chain/Chains.get_children():
		if chain is RigidBody2D:
			chain.apply_force(force * chain.position.length())
