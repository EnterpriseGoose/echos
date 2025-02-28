extends CharacterBody2D
class_name Player

@export var speed = 50
@export var jump_speed = 50
@export var gravity = 0
@export var lantern: Lantern
@export var echo_pulse_parent: Node2D
@export var fireball_parent: Node2D
@export var lantern_energy = 1.5
@export var fireballs_enabled = false
var echo_pulse = preload("res://scenes/echo_pulse.tscn")
var force_pulse = preload("res://scenes/force_pulse.tscn")
var fireball = preload("res://scenes/fireball.tscn")
var forceball = preload("res://scenes/forceball.tscn")

var speed_mod = 1

func _ready() -> void:
	Global.player = self
	lantern.fade_light(lantern_energy)
	Global.player_view_changed.connect(_on_player_view_changed)
	$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	if Input.is_action_pressed("player_sprint"):
		speed_mod = 1.4
	else:
		speed_mod = 1
	if Global.player_view == Global.VIEW.FLY:
		velocity.y = max(velocity.y - gravity * delta * 5, -75)
		lantern.collider.gravity_scale = -1
	else:	
		velocity.y += gravity * delta * 100
		lantern.collider.gravity_scale = 1
	if Input.is_action_pressed("player_right"):
		if is_on_floor():
			velocity.x = speed * delta * 1000 * speed_mod
		else:
			velocity.x += speed * delta * 0 * speed_mod
	if Input.is_action_pressed("player_left"):
		if is_on_floor():
			velocity.x = speed * delta * -1000 * speed_mod
		else:
			velocity.x += speed * delta * 0 * speed_mod
	if is_on_floor():
		velocity.x *= .75
	else:
		velocity.x *= .995
	
	if (abs(velocity.y) > 30 or not is_on_floor()) and abs(velocity.x) > 10:
		if $AnimatedSprite2D.animation != "jump":
			$AnimatedSprite2D.play("jump")
	elif (abs(velocity.y) > 30 or not is_on_floor()):
		if $AnimatedSprite2D.animation != "idle":
			$AnimatedSprite2D.play("idle")
	elif abs(velocity.x) > 10:
		if $AnimatedSprite2D.animation != "run":
			$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.speed_scale = velocity.x / 300
	elif $AnimatedSprite2D.animation != "idle":
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.speed_scale = 1
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$Arm.flip_h = false
		$Arm.position.x = 64.175
		$Lantern.position.x = 81
		$PinJoint2D.position.x = 81
		$StaticBody2D.position.x = 81
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$Arm.flip_h = true
		$Arm.position.x = -64.175
		$Lantern.position.x = -81
		$PinJoint2D.position.x = -81
		$StaticBody2D.position.x = -81
	
	lantern.collider.apply_force(Vector2.RIGHT * -velocity.x, Vector2(0, 50))
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_jump") and is_on_floor():
		velocity.y -= 100 * jump_speed		
	if event.is_action_pressed("left_click"):
		if Global.player_view == Global.VIEW.NONE and lantern.energy_used + .5 < lantern.light_level and fireballs_enabled:
			var delta = get_viewport().get_mouse_position() - (lantern.get_global_transform_with_canvas().origin + Vector2.DOWN * 50)
			var angle = atan2(delta.y, delta.x)
			var ball = forceball.instantiate() if Global.player_view_force else fireball.instantiate()
			ball.global_position = lantern.global_position + Vector2.DOWN * 50
			ball.rotation = angle
			fireball_parent.add_child(ball)
			lantern.energy_used = min(lantern.energy_used + .35, lantern.light_level)
		if Global.player_view == Global.VIEW.ECHO:
			var pulse = force_pulse.instantiate() if Global.player_view_force else echo_pulse.instantiate()
			pulse.global_position = lantern.global_position
			echo_pulse_parent.add_child(pulse)
		
func _process(delta: float) -> void:
	lantern.energy_used = max(lantern.energy_used - .1 * delta, 0)

func _on_player_view_changed(view: Global.VIEW):
	if view == Global.VIEW.NONE:
		lantern.fade_light(lantern_energy)
	else:
		lantern.fade_light(.1)

signal player_die

func hit_by_enemy(enemy: Enemy):
	if lantern.light_level - lantern.energy_used < .5:
		player_die.emit()
		Global.game_state = Global.GAME_STATE.LOSE
	lantern.energy_used = min(lantern.energy_used + .5, lantern.light_level)
	
