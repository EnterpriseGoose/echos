extends RigidBody2D
class_name Lantern

@export var light: PointLight2D
@export var enemy_light: PointLight2D
@export var light_level: float
@export var energy_used: float = 0
@export var max_level: float = 2

signal lantern_lit

var old_light_range: float = 0
var new_light_range: float = light_level

var light_range = light_level

@export var logger = false

func _ready() -> void:
	if light_level == 0:
		$Flame.play("none")
	elif light_level > .5:
		if Global.player_view == Global.VIEW.FORCE:
			$Flame.play("force")
		else:
			$Flame.play("fire")
	elif light_level < .5:
		if Global.player_view == Global.VIEW.FORCE:
			$Flame.play("force_small")
		else:
			$Flame.play("fire_small")
	
func _process(delta: float) -> void:
	if logger:
		print(light_level, ' ', light_range, ' ', new_light_range, ' ', old_light_range)
	#if Global.player_view == Global.VIEW.ECHO && $RigidBody2D/Outline.modulate.a < 1:
		#$RigidBody2D/Outline.modulate.a = min(1, $RigidBody2D/Outline.modulate.a + delta / 2)
	#else:
		#if $RigidBody2D/Outline.modulate.a > 0:
			#$RigidBody2D/Outline.modulate.a = max(0, $RigidBody2D/Outline.modulate.a - delta * 3)
	
	if Global.dying:
		new_light_range = 0
		light_range = 0
	elif Global.player_view != Global.VIEW.FLAME and Global.player_view != Global.VIEW.FORCE and (light_level > 0 and new_light_range >= light_level) or (light_level < 0 and new_light_range < 0):
		new_light_range = 0.1
	else:
		new_light_range = light_level
	if new_light_range != light_range:
		if (new_light_range > light_range):
			light_range += (new_light_range - old_light_range) * delta * randf_range(-1.5 , 2)
		else:
			light_range += (new_light_range - old_light_range) * delta * randf_range(-1 , 2)
		if (new_light_range > old_light_range && light_range > new_light_range) || (new_light_range < old_light_range && light_range < new_light_range):
			pass
			light_range = new_light_range
	if light_range != 0:
		light.texture_scale = max(0, randf_range(max(0, light_range-energy_used-.15, light.texture_scale - 0.02), min(light_range-energy_used+.15, light.texture_scale + 0.02)))
		enemy_light.texture_scale = light.texture_scale + 0.2
	else:
		light.texture_scale = 0
		enemy_light.texture_scale = 0
	if Global.player_view == Global.VIEW.FLY and light_range > 0:
		directional_light_level = min(1, directional_light_level + delta * .5)
	else:
		directional_light_level = max(0, directional_light_level - delta * 2)
	
	if directional_light_level > 0:
		set_directional_light_level(max(0, randf_range(max(0, directional_light_level-.15, $DirectionalLight.texture_scale - 0.02), min(directional_light_level+.15, $DirectionalLight.texture_scale + 0.02))))
	else:
		set_directional_light_level(0)
		
	if Global.player_view == Global.VIEW.FORCE:
		light.color = "#d4f1f0"
	else:
		light.color = "#ffffd9"

func fade_light(level: float) -> void:
	if light_level < .5 and level > .5:
		if Global.player_view == Global.VIEW.FORCE:
			$Flame.play("force_fade_in")
		else:
			$Flame.play("fire_fade_in")
	if light_level > .5 and level < .5:
		if Global.player_view == Global.VIEW.FORCE:
			$Flame.play("force_fade_out")
		else:
			$Flame.play("fire_fade_out")
	
	light_level = level
	old_light_range = light_range
	
	
	
var directional_light_level = 0

func set_directional_light_level(level: float):
	$DirectionalLight.texture_scale = level
	$DirectionalLight.energy = 1 + level
	$DirectionalLight.offset.y = (1 - level) * -256

func _on_flame_animation_finished() -> void:
	if $Flame.animation == "fire_fade_in":
		$Flame.play("fire")
		$Flame.autoplay
	if $Flame.animation == "fire_fade_out":
		$Flame.play("fire_small")
		
	if $Flame.animation == "force_fade_in":
		$Flame.play("force")
	if $Flame.animation == "force_fade_out":
		$Flame.play("force_small")


func _on_lit_area_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if (parent is Fireball or (parent is Lantern and parent.light_level > 0)) and light_level == 0:
		fade_light(max_level)
		lantern_lit.emit()
		
		if parent is Fireball:
			parent.fading = true
			parent.speed = 0.05
