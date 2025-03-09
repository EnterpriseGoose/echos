extends CharacterBody2D
class_name Player

@export var speed: float = 35
@export var jump_speed: float = 6.5
@export var gravity: float = 15
@export var lantern: Lantern
@export var echo_pulse_parent: Node2D
@export var fireball_parent: Node2D
@export var lantern_energy = 2
@export var fireballs_enabled = false
var echo_pulse = preload("res://scenes/echo_pulse.tscn")
var force_pulse = preload("res://scenes/force_pulse.tscn")
var fireball = preload("res://scenes/fireball.tscn")
var forceball = preload("res://scenes/forceball.tscn")

var speed_mod = 1
var lantern_time = 0
var coyote_time = 0
var jump_buffer = 0

func _ready() -> void:
	Global.player = self
	lantern.fade_light(lantern_energy)
	Global.player_view_changed.connect(_on_player_view_changed)
	$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	if Input.is_action_pressed("player_sprint"):
		speed_mod = 1.25
	else:
		speed_mod = 1
	if Global.player_view == Global.VIEW.FLY:
		velocity.y = max(velocity.y - gravity * delta * 5, -75)
	else:	
		velocity.y += gravity * delta * 100
	if Input.is_action_pressed("player_right"):
		if is_on_floor() or true:
			velocity.x = speed * delta * 1000 * speed_mod
		else:
			velocity.x += speed * delta * 0 * speed_mod
	if Input.is_action_pressed("player_left"):
		if is_on_floor() or true:
			velocity.x = speed * delta * -1000 * speed_mod
		else:
			velocity.x += speed * delta * 0 * speed_mod
	if is_on_floor():
		velocity.x *= .75
	else:
		velocity.x *= .65
	
	if (abs(velocity.y) > 30 or not is_on_floor()) and abs(velocity.x) > 10:
		if $AnimatedSprite2D.animation != "jump":
			$AnimatedSprite2D.play("jump")
			$AnimatedSprite2D.speed_scale = 1
	elif (abs(velocity.y) > 30 or not is_on_floor()):
		if $AnimatedSprite2D.animation != "idle":
			$AnimatedSprite2D.play("idle")
			$AnimatedSprite2D.speed_scale = 1
	elif abs(velocity.x) > 10:
		if $AnimatedSprite2D.animation != "run":
			$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.speed_scale = velocity.x / 300
	elif $AnimatedSprite2D.animation != "idle":
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.speed_scale = 1
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$LanternGoal.position.x = 81
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$LanternGoal.position.x = -81
		
		
	if is_on_floor():
		coyote_time = .1
		if jump_buffer > 0:
			velocity.y -= 100 * jump_speed
			jump_buffer = 0
	elif coyote_time > 0:
		coyote_time = max(0, coyote_time - delta)
	
	jump_buffer = max(0, jump_buffer - delta)
		
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_jump"):
		if is_on_floor() or coyote_time > 0:
			velocity.y -= 100 * jump_speed
		else:
			jump_buffer = .1
	if event.is_action_pressed("left_click"):
		if Global.player_view == Global.VIEW.NONE and lantern.energy_used + .5 < lantern.light_level and fireballs_enabled:
			var delta = get_viewport().get_mouse_position() - (lantern.get_global_transform_with_canvas().origin + Vector2.DOWN * 25)
			var angle = atan2(delta.y, delta.x)
			var ball = forceball.instantiate() if Global.player_view_force else fireball.instantiate()
			ball.global_position = lantern.global_position + Vector2.DOWN * 25
			ball.rotation = angle
			fireball_parent.add_child(ball)
			lantern.energy_used = min(lantern.energy_used + (.2 if Global.player_view_force else .35), lantern.light_level)
		if Global.player_view == Global.VIEW.ECHO:
			var pulse = force_pulse.instantiate() if Global.player_view_force else echo_pulse.instantiate()
			pulse.global_position = lantern.global_position
			echo_pulse_parent.add_child(pulse)
		
func _process(delta: float) -> void:
	lantern.energy_used = max(lantern.energy_used - .1 * delta, 0)
	
	lantern_time += delta
	$LanternGoal.position.y = -20 + sin(lantern_time * 2) * 20
	lantern.position += ($LanternGoal.position - lantern.position) * delta * 3

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
	
