extends Node2D
class_name Lightpost

@export var light_level: float = 0:
	set(value):
		lantern.light_level = value
		light_level = value
@export var lantern: Lantern


func _ready() -> void:
	lantern.light_level = light_level

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.player.lantern.collider:
		light_up()
		Global.player.lantern.energy_used = 0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Fireball:
		light_up()


func light_up():
	if lantern.light_level == 0:
		Global.player.lantern_energy += .5
		Global.player.lantern.fade_light(Global.player.lantern_energy)
		lantern.fade_light(1)
	lantern.collider.apply_force(Vector2.RIGHT * Global.player.velocity.x * 10, Vector2(0, 50))
	
