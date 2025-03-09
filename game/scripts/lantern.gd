extends RigidBody2D
class_name Lantern

@export var light: PointLight2D
@export var enemy_light: PointLight2D
@export var light_level: float
@export var energy_used: float = 0

var old_light_range: float = 0
var new_light_range: float = light_level

var light_range = light_level

@export var logger = false

func _ready() -> void:
	$Flame.play("fire")
	
	Global.player_view_force_changed.connect(_on_player_view_force_changed)

func _process(delta: float) -> void:
	if logger:
		print(light_level, ' ', light_range, ' ', new_light_range, ' ', old_light_range)
	#if Global.player_view == Global.VIEW.ECHO && $RigidBody2D/Outline.modulate.a < 1:
		#$RigidBody2D/Outline.modulate.a = min(1, $RigidBody2D/Outline.modulate.a + delta / 2)
	#else:
		#if $RigidBody2D/Outline.modulate.a > 0:
			#$RigidBody2D/Outline.modulate.a = max(0, $RigidBody2D/Outline.modulate.a - delta * 3)
	if Global.player_view != Global.VIEW.NONE and (light_level > 0 and new_light_range >= light_level) or (light_level < 0 and new_light_range < 0):
		#light_range = 0.1
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
		

func fade_light(level: float) -> void:
	if light_level < .5 and level > .5:
		$Flame.play("fade_in")
	if light_level > .5 and level < .5:
		$Flame.play("fade_out")
	
	light_level = level
	old_light_range = light_range
	
	
	
var directional_light_level = 0

func set_directional_light_level(level: float):
	$DirectionalLight.texture_scale = level
	$DirectionalLight.energy = 1 + level
	$DirectionalLight.offset.y = (1 - level) * -256

func _on_player_view_force_changed(force_mode: bool):
	if force_mode:
		if light_level > .5:
			$Flame.play("force")
		else:
			$Flame.play("force")
		$MainLight.color = "#d4f1f0"
		$DirectionalLight.color = "#d4f1f0"
	else:
		if light_level > .5:
			$Flame.play("fire")
		else:
			$Flame.play("fire_small")
		$MainLight.color = "#ffffd9"
		$DirectionalLight.color = "#ffffd9"


func _on_flame_animation_finished() -> void:
	if $Flame.animation == "fade_in":
		$Flame.play("fire")
	if $Flame.animation == "fade_out":
		$Flame.play("fire_small")
