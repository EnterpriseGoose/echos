extends Node2D
class_name Door

@export var open = false:
	set(state):
		open = state
		if $CameraBarrier/CollisionShape2D:
			$CameraBarrier/CollisionShape2D.set_deferred_thread_group("disabled", open)
@export var triggers_req = 0

@export var triggers: Array[Lantern]

var doorLit = false

signal doorOpened()

func _ready() -> void:
	for trigger in triggers:
		trigger.lantern_lit.connect(_on_lantern_lit)
	if open:
		$UpperHalf.position.y = -200
		$LowerHalf.position.y = 200
		
	for i in range(1, len(triggers) + 1):
		find_child("LightSprite" + str(i)).visible = true
	_on_lantern_lit()

func _process(delta: float) -> void:
	var t = $UpperHalf.position.y / -200
	if open and t < 1:
		$UpperHalf.position.y -= 100 * delta * (2 * sin(PI * t) + 0.1)
		$LowerHalf.position.y = -$UpperHalf.position.y
	elif not open and t > 0:
		$UpperHalf.position.y += 100 * delta * (2 * sin(PI * t) + 0.1)
		$LowerHalf.position.y = -$UpperHalf.position.y
		
	if len(fading_lights) > 0:
		var to_remove = []
		for fading_light in fading_lights:
			if fading_light.size > fading_light.light.texture_scale:
				fading_light.light.texture_scale = min(fading_light.size, fading_light.light.texture_scale + delta * fading_light.speed)
			elif fading_light.size < fading_light.light.texture_scale:
				fading_light.light.texture_scale = max(fading_light.size, fading_light.light.texture_scale - delta * fading_light.speed)
				
			if abs(fading_light.size - fading_light.light.texture_scale) < 0.1:
				to_remove.append(fading_light)
			
			if fading_light.light.texture_scale < 0.1:
				fading_light.light.enabled = false
			else:
				fading_light.light.enabled = true
				
		for remove in to_remove:
			fading_lights.erase(remove)

var triggersOn = 0

func _on_lantern_lit():
	triggersOn = 0
	for i in range(1, len(triggers) + 1):
		if triggers[i - 1].light_level > 0:
			triggersOn += 1
			fading_lights.append({"light": find_child("Light" + str(i)), "size": 1, "speed": 1})
			fading_lights.append({"light": find_child("LightLight" + str(i)), "size": .5, "speed": 1})
		else:
			fading_lights.append({"light": find_child("Light" + str(i)), "size": 0, "speed": 1})
			fading_lights.append({"light": find_child("LightLight" + str(i)), "size": 0, "speed": 1})
		
	#open = triggersOn >= triggers_req

var fading_lights = []	

func _on_center_light_area_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is not Fireball or open:
		return
	_on_lantern_lit()
	fading_lights.append({"light": $LowerHalf/CenterLight, "size": 1, "speed": 1})
	fading_lights.append({"light": $UpperHalf/CenterLight, "size": 1, "speed": 1})
	parent.fading = true
	parent.speed = 0.05
	if triggersOn >= triggers_req:
		await get_tree().create_timer(1).timeout
		open = true
		doorOpened.emit()
	else:
		await get_tree().create_timer(2).timeout
		fading_lights.append({"light": $LowerHalf/CenterLight, "size": 0, "speed": 1})
		fading_lights.append({"light": $UpperHalf/CenterLight, "size": 0, "speed": 1})
