extends CharacterBody2D
class_name Player

@export var speed: float = 35
@export var jump_speed: float = 8
@export var gravity: float = 20
@export var lantern: Lantern
@export var echo_pulse_parent: Node2D
@export var fireball_parent: Node2D
@export var lantern_energy = 2
@export var fireballs_enabled = false
@export var lantern_enabled = false:
	set(state):
		lantern_enabled = state
		if lantern:
			lantern.visible = state
		if !state and fireballs_enabled:
			fireballs_enabled = false
var echo_pulse = preload("res://scenes/echo_pulse.tscn")
var force_pulse = preload("res://scenes/force_pulse.tscn")
var fireball = preload("res://scenes/fireball.tscn")
var forceball = preload("res://scenes/forceball.tscn")

var frozen = false
var freeze_lantern = false
var speed_mod = 1
var lantern_time = 0
var coyote_time = 0
var jump_buffer = 0

func _ready() -> void:
	Global.player = self
	lantern.fade_light(lantern_energy)
	Global.player_view_changed.connect(_on_player_view_changed)
	$AnimatedSprite2D.play("idle")
	if lantern_enabled:
		lantern.visible = true
		fireballs_enabled = true
	else:
		lantern.visible = false
		fireballs_enabled = false

func _physics_process(delta):
	if Input.is_action_pressed("player_sprint") and not Global.dying:
		speed_mod = 1.25
	else:
		speed_mod = 1
	if Global.player_view == Global.VIEW.FLY:
		velocity.y = max(velocity.y - gravity * delta * 5, -75)
	elif not is_on_floor():
		velocity.y += gravity * delta * 100
	if Input.is_action_pressed("player_right") and not Global.dying and not frozen:
		if is_on_floor() or true:
			velocity.x = speed * delta * 1000 * speed_mod
		else:
			velocity.x += speed * delta * 0 * speed_mod
	if Input.is_action_pressed("player_left") and not Global.dying and not frozen:
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
		$LanternGoal.position.x = 55
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$LanternGoal.position.x = -55
		
		
	if is_on_floor():
		coyote_time = .1
		if jump_buffer > 0:
			velocity.y -= 100 * jump_speed
			jump_buffer = 0
	elif coyote_time > 0:
		coyote_time = max(0, coyote_time - delta)
	
	jump_buffer = max(0, jump_buffer - delta)
	echo_cooldown = max(0, echo_cooldown - delta)
	
	if frozen:
		velocity = Vector2.ZERO
	move_and_slide()

var echo_cooldown = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_jump") and not Global.dying and not frozen:
		if is_on_floor() or coyote_time > 0:
			velocity.y -= 100 * jump_speed * (speed_mod + 2) / 3
		else:
			jump_buffer = .1
	if event.is_action_pressed("left_click") and not Global.dying and not frozen:
		if (Global.player_view == Global.VIEW.FLAME or Global.player_view == Global.VIEW.FORCE) and lantern.energy_used + .5 < lantern.light_level and fireballs_enabled:
			var delta = get_viewport().get_mouse_position() - (lantern.get_global_transform_with_canvas().origin + Vector2.DOWN * 25)
			var angle = atan2(delta.y, delta.x)
			var ball = forceball.instantiate() if Global.player_view == Global.VIEW.FORCE else fireball.instantiate()
			ball.global_position = lantern.global_position + Vector2.DOWN * 25
			ball.rotation = angle
			fireball_parent.add_child(ball)
			lantern.energy_used = min(lantern.energy_used + (.2 if Global.player_view == Global.VIEW.FORCE else .35), lantern.light_level)
		if Global.player_view == Global.VIEW.ECHO and echo_cooldown == 0:
			echo_cooldown = 1
			var pulse = echo_pulse.instantiate()
			pulse.global_position = lantern.global_position
			echo_pulse_parent.add_child(pulse)
		
func _process(delta: float) -> void:
	lantern.energy_used = max(lantern.energy_used - .1 * delta, 0)
	
	lantern_time += delta
	if not freeze_lantern:
		$LanternGoal.position.y = -20 + sin(lantern_time * 2) * 20
	lantern.position.y = $LanternGoal.position.y
	lantern.position.x += ($LanternGoal.position.x - lantern.position.x) * delta * 3

func _on_player_view_changed(view: Global.VIEW):
	if view == Global.VIEW.FLAME or view == Global.VIEW.FORCE:
		lantern.fade_light(lantern_energy)
	else:
		lantern.fade_light(.1)

signal player_die
var last_checkpoint: Checkpoint	

func die():
	print('die!')
	Global.dying = true
	var temp_energy = lantern_energy
	lantern_energy = 0
	lantern.fade_light(0)
	lantern.light_range = 0
	global_position = Vector2.ZERO if not last_checkpoint else last_checkpoint.respawn_pt.global_position
	await get_tree().create_timer(2).timeout
	global_position = Vector2.ZERO if not last_checkpoint else last_checkpoint.respawn_pt.global_position
	lantern_energy = temp_energy
	lantern.light_range = 0.05
	lantern.fade_light(temp_energy)
	Global.dying = false
