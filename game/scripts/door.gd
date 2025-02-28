extends Node2D
class_name Door

@export var open = false
@export var triggers_req = 0

@export var triggers: Array[HangingLantern]

@onready var spriteHeight = $StaticBody2D/Sprite2D.texture.get_size().y * $StaticBody2D/Sprite2D.scale.y


func _ready() -> void:
	for trigger in triggers:
		trigger.state_changed.connect(_on_trigger_state_changed)
	if open:
		$StaticBody2D.position.y = -spriteHeight

func _process(delta: float) -> void:
	var t = $StaticBody2D.position.y / -spriteHeight
	if open and t < 1:
		$StaticBody2D.position.y -= 100 * delta * (2 * sin(PI * t) + 0.1)
	elif not open and t > 0:
		$StaticBody2D.position.y += 100 * delta * (2 * sin(PI * t) + 0.1)

func _on_trigger_state_changed():
	var triggersOn = 0
	for trigger in triggers:
		if trigger.on:
			triggersOn += 1
	open = triggersOn >= triggers_req
	$CameraBarrier/CollisionShape2D.set_deferred_thread_group("disabled", open)
