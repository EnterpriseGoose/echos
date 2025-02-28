extends Node2D

@export var light_level: float

var old_light_range: float = 0
var new_light_range: float = light_level

var light_range = light_level

@export var logger = false

func _ready() -> void:
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
		new_light_range = 0.05
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
		$PointLight2D.texture_scale = max(0, randf_range(max(0, light_range-.08, $PointLight2D.texture_scale - 0.02), min(light_range+.08, $PointLight2D.texture_scale + 0.02)))
	else:
		$PointLight2D.texture_scale = 0
		
	if (Global.player.global_position - global_position).length_squared() <= 200**2 and light_level > 0:
		print("fade")
		fade_light(0)
		
	if light_range == 0 and $Sprite.modulate.a > 0:
		print($Sprite.modulate.a)
		$Sprite.modulate.a = max(0, $Sprite.modulate.a - delta)
		

func fade_light(level: float) -> void:
	light_level = level
	old_light_range = light_range
	
	

func _on_player_view_force_changed(force_mode: bool):
	if force_mode:
		$PointLight2D.color = "#d4f1f0"
	else:
		$PointLight2D.color = "#ffffd9"
