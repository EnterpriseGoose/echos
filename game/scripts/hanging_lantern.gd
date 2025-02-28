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

var on = false

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
		lantern.collider.constant_force = (sin(Time.get_unix_time_from_system() / swing * 5) * Vector2.RIGHT * 100 * swing)
		
		for chain in $Chain/Chains.get_children():
			if chain is RigidBody2D:
				chain.constant_force = (sin(Time.get_unix_time_from_system() / swing * 5) * Vector2.RIGHT * 100 * swing)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Fireball:
		light_level = max_level
		lantern.collider.apply_force(Vector2.RIGHT * Global.player.velocity.x * 10, Vector2(0, 50))
		on = true
		state_changed.emit()
		
func push(force: Vector2, pos: Vector2):
	lantern.collider.apply_force(force * lantern.position.length())
		
	for chain in $Chain/Chains.get_children():
		if chain is RigidBody2D:
			chain.apply_force(force * chain.position.length())
