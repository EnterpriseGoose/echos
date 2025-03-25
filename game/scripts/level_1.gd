extends Node2D
class_name Level1

@export var camera: CameraFollower

@export_group("Section 1")
@export var enemies_1: Array[Enemy]

@export_group("Section 2")
@export var respawn_pt_2: Node2D

var level_state = 0
@onready var spectrum = AudioServer.get_bus_effect_instance(0, 0)
var lightning_cooldown = false

var power_core_level = 3.5

func _ready() -> void:
	$"2/LightPowerCore".play("test")
	$"5/Chain/Pin2/Bat".play("fly")
	$"5/Chain/Pin2/Bat".speed_scale = 1
	

func _process(delta: float) -> void:
	$Rain.global_position.x = camera.global_position.x
	$RainSound.global_position.x = camera.global_position.x
	
	if level_state == 1 and spectrum.get_magnitude_for_frequency_range(0, 10000).length() * 100 > 3:
		#print("loud2")
		#print(spectrum.get_magnitude_for_frequency_range(0, 10000).length() * 100)
		if randf_range(0, 1) > .85 and not lightning_cooldown:
			lightning(.2 + (spectrum.get_magnitude_for_frequency_range(0, 10000).length() * 100 - 3))
			lightning_cooldown = true
	
	if level_state == 1 and $Parallax2D/WideLight.texture_scale < 20:
		$Parallax2D/WideLight.texture_scale = min(20, $Parallax2D/WideLight.texture_scale + delta * 5)
	if level_state == 1 and $Parallax2D/MoonLight.texture_scale < 20:
		$Parallax2D/MoonLight.texture_scale = min(2.5, $Parallax2D/MoonLight.texture_scale + delta)
		
	$"2/LightPowerCoreLight".texture_scale = max(0, randf_range(max(0, power_core_level-.2, $"2/LightPowerCoreLight".texture_scale - 0.02), min(power_core_level+.2, $"2/LightPowerCoreLight".texture_scale + 0.02)))
	$"2/LightPowerCoreLight".energy = max(0, randf_range(max(0, 3, $"2/LightPowerCoreLight".energy - 0.03), min(4, $"2/LightPowerCoreLight".energy + 0.03)))
	
	if level_state >= 2.1 and level_state < 4 and power_core_level > 1:
		power_core_level -= delta * .5
	
	if level_state >= 2.2 and level_state < 4 and Global.player.lantern.modulate.a < 1:
		Global.player.lantern.modulate.a = min(1, Global.player.lantern.modulate.a + delta)
		
	if level_state == 2.3:
		Global.player.find_child("LanternGoal").position.y = min(-20, Global.player.find_child("LanternGoal").position.y + delta * 100)
	
	if level_state == 2.5:
		if has_clicked:
			$KeyHints/LeftClick.modulate.a = max(0, $KeyHints/LeftClick.modulate.a - delta / 2)
		else:
			$KeyHints/LeftClick.modulate.a = min(0.5, $KeyHints/LeftClick.modulate.a + delta / 2)
	
	if level_state == 3.1:
		if has_sprinted:
			$KeyHints/Shift.modulate.a = max(0, $KeyHints/Shift.modulate.a - delta / 2)
		else:
			$KeyHints/Shift.modulate.a = min(0.5, $KeyHints/Shift.modulate.a + delta / 2)
			
	if level_state == 5.1 and $"5/Chain/Pin2/Light".texture_scale < 2:
		$"5/Chain/Pin2/Light".texture_scale = min(2, $"5/Chain/Pin2/Light".texture_scale + delta / 2)
		
func lightning(level: float):
	$Lightning/Light.modulate.a = level - .2
	$Lightning/Bolt.modulate.a = 1
	
	for i in range(randi_range(1, 5)):
		$Lightning/Light.modulate.a = randf_range(level - .2, level + .2)
		if randf_range(0, 1) > .75:
			$Lightning/Bolt.scale = Vector2.ONE * (.5 + randf_range(level - .2, level + .2))
			$Lightning/Bolt.position.x = randf_range(200, 1700)
		await get_tree().create_timer(.05).timeout
	$Lightning/Light.modulate.a = 0
	$Lightning/Bolt.modulate.a = 0
	await get_tree().create_timer(.1).timeout
	lightning_cooldown = false

func _on_die_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
		
func _on_fall_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		lightning(1)
		level_state = 2

func _on_power_up_area_body_entered(body: Node2D) -> void:
	if body is Player and not body.lantern_enabled:
		body.frozen = true
		level_state = 2.1
		body.freeze_lantern = true
		body.lantern.position.y = -910
		body.find_child("LanternGoal").position.y = -910
		body.lantern.modulate.a = 0
		body.lantern.fade_light(0)
		$"2/LightPowerCore".play("power_down")
		level_state = 2.2
		body.lantern.fade_light(body.lantern_energy)
		body.lantern_enabled = true
		await get_tree().create_timer(2).timeout
		level_state = 2.3
		while body.find_child("LanternGoal").position.y < -20:
			await get_tree().create_timer(.1).timeout
		level_state = 2.4
		body.freeze_lantern = false
		body.frozen = true
		body.fireballs_enabled = true
		body.lantern_time = 0

var has_clicked = false
var has_sprinted = false
var has_switched_lantern = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and not has_clicked and Global.player.fireballs_enabled:
		has_clicked = true
	if event.is_action_pressed("player_sprint") and not has_sprinted and level_state >= 3:
		has_sprinted = true
	if event.is_action_pressed("switch_lantern") and has_switched_lantern == 0 and level_state >= 5:
		has_switched_lantern = 1
		while $KeyHints/RightClick.modulate.a > 0:
			$KeyHints/RightClick.modulate.a -= 0.01
			await get_tree().create_timer(.02).timeout
		while $KeyHints/LeftClick.modulate.a < .5:
			$KeyHints/LeftClick.modulate.a += 0.01
			await get_tree().create_timer(.02).timeout
	if event.is_action_pressed("left_click") and has_switched_lantern == 1:
		has_switched_lantern = 2
		while $KeyHints/LeftClick.modulate.a > 0:
			$KeyHints/LeftClick.modulate.a -= 0.01
			await get_tree().create_timer(.02).timeout

func _on_click_hint_area_body_entered(body: Node2D) -> void:
	if body is Player and level_state < 2.5:
		await get_tree().create_timer(2).timeout
		level_state = 2.5

func _on_door_2_door_opened() -> void:
	level_state = 3
	
func _on_fall_zone_3_body_entered(body: Node2D) -> void:
	if body is Player:
		await get_tree().create_timer(2).timeout
		level_state = 3.1

func _on_bat_free_area_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is not Fireball or level_state >= 5.1:
		return
	parent.fading = true
	parent.speed = 0.05
	var player = Global.player
	player.frozen = true
	level_state = 5.1
	$"5/Chain/Pin2/Light".texture_scale = 0
	$"5/Chain/Pin2/Light".energy = 1
	var bat = $"5/Chain/Pin2/Bat"
	while bat.modulate.a > 0:
		bat.modulate.a -= 0.01
		await get_tree().create_timer(.01).timeout
	bat.z_index = 1
	while bat.modulate.a < 1:
		bat.modulate.a += 0.01
		await get_tree().create_timer(.01).timeout
	bat.speed_scale = 2.5
	while abs(bat.global_position - player.lantern.global_position).length_squared() > 10 ** 2:
		bat.global_position += (player.lantern.global_position - bat.global_position).normalized() * 1
		await get_tree().create_timer(.01).timeout
	while bat.modulate.a > 0:
		bat.modulate.a -= 0.01
		$"5/Chain/Pin2/Cage".modulate.a = bat.modulate.a
		$"5/Chain/Pin2/SmallLightSprite".modulate.a = bat.modulate.a
		$"5/Chain/Pin2/Light".energy = bat.modulate.a
		await get_tree().create_timer(.01).timeout
	player.frozen = false
	Global.views_unlocked.append(Global.VIEW.ECHO)
	await get_tree().create_timer(2).timeout
	while $KeyHints/RightClick.modulate.a < .5:
		$KeyHints/RightClick.modulate.a += 0.01
		await get_tree().create_timer(.02).timeout
