extends RigidBody2D
class_name Enemy

enum ENEMY_TYPE {SAD, MAD, FEAR}
@export var type: ENEMY_TYPE = ENEMY_TYPE.SAD
@export var frozen = false
@export var enemy_speed = 100

var dying = false
var add_force = Vector2.ZERO
var speed = 1
var boost = Vector2.ZERO
var boosting = false
var force_to_apply = Vector2.ZERO

@export var logger = false

func _ready() -> void:
	if type == ENEMY_TYPE.MAD:
		$Body.play("mad")
		$Outline.play("mad")
	if type == ENEMY_TYPE.SAD:
		$Body.play("sad")
		$Outline.play("sad")
	if type == ENEMY_TYPE.FEAR:
		$Body.play("fear")
		$Outline.play("fear")

func _process(delta: float) -> void:
	$Outline.frame = $Body.frame
	
	force_to_apply = Vector2.ZERO
	var rot_mod = fmod(rotation, 2 * PI)
	if rot_mod > PI/2 and rot_mod < 3 * PI/2 or rot_mod < -PI/2 and rot_mod > -3 * PI/2:
		$Body.flip_v = 1
		$Outline.flip_v = 1
	else:
		$Body.flip_v = 0
		$Outline.flip_v = 0
	
	if Global.player_view == Global.VIEW.ECHO:
		$Outline.modulate.a = 1
	else:
		$Outline.modulate.a = 0
		
	if dying:
		$Body.modulate.a -= 1 * delta
		
		if $Body.modulate.a <= 0:
			queue_free()
	else:
		var delta_pos = (Global.player.lantern.global_position + Vector2.DOWN * 50) - global_position
		if delta_pos.x ** 2 + delta_pos.y ** 2 < 1920 ** 2 and not frozen:
			if type != ENEMY_TYPE.FEAR:
				force_to_apply = delta_pos.normalized() * delta * enemy_speed * speed + add_force
			else:
				position += add_force
				boost += (delta_pos / sqrt(delta_pos.x ** 2 + delta_pos.y ** 2) * delta * enemy_speed) * speed
				if boost.length_squared() > 100 ** 2:
					boosting = true
				if boosting:
					position += boost / 30
					boost *= .98
					boost -= boost.normalized()
				if boost.length_squared() < 25:
					boosting = false
			if add_force.length_squared() > 0:
				add_force = Vector2.ZERO
			
			var delta_angle = (atan2(delta_pos.y, delta_pos.x)) - rotation
			if delta_angle < -PI:
				delta_angle += 2 * PI
			if delta_angle > PI:
				delta_angle -= 2 * PI
			rotation += (delta_angle) * delta * 15
			rotation = fmod(rotation, 2 * PI)
			
			if speed < 1 and type == ENEMY_TYPE.MAD:
				speed = min(1, speed + delta / 10)
	
	
	move_and_collide(force_to_apply)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and body.is_in_group("Player") and not dying:
		var player: Player = body.find_parent("Player")
		player.die()
		dying = true

func kill():
	dying = true
	$DeadLight.enabled = true
