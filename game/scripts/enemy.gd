extends Node2D
class_name Enemy

enum ENEMY_TYPE {SAD, MAD, FEAR}
@export var type: ENEMY_TYPE = ENEMY_TYPE.SAD
@export var frozen = false

var dying = false
var add_force = Vector2.ZERO
var speed = 1
var boost = Vector2.ZERO
var boosting = false

func _ready() -> void:
	if type == ENEMY_TYPE.MAD:
		$RigidBody2D/AnimatedSprite2D.play("mad")
	if type == ENEMY_TYPE.SAD:
		$RigidBody2D/AnimatedSprite2D.play("sad")
	if type == ENEMY_TYPE.FEAR:
		$RigidBody2D/AnimatedSprite2D.play("fear")

func _process(delta: float) -> void:
	var rot_mod = fmod(rotation, 2 * PI)
	if rot_mod > PI/2 and rot_mod < 3 * PI/2 or rot_mod < -PI/2 and rot_mod > -3 * PI/2:
		$RigidBody2D/AnimatedSprite2D.flip_v = 1
		#$RigidBody2D/Outline.flip_v = 1
	else:
		$RigidBody2D/AnimatedSprite2D.flip_v = 0
		#$RigidBody2D/Outline.flip_v = 0
	
	#if Global.player_view == Global.VIEW.ECHO:
		#$RigidBody2D/Outline.modulate.a = 1
	#else:
		#$RigidBody2D/Outline.modulate.a = 0
		
	if dying:
		$RigidBody2D/AnimatedSprite2D.modulate.a -= 1 * delta
		
		if $RigidBody2D/AnimatedSprite2D.modulate.a <= 0:
			queue_free()
	else:
		var delta_pos = (Global.player.lantern.global_position + Vector2.DOWN * 50) - global_position
		if delta_pos.x ** 2 + delta_pos.y ** 2 < 1920 ** 2 and not frozen:
			if type != ENEMY_TYPE.FEAR:
				position += (delta_pos / sqrt(delta_pos.x ** 2 + delta_pos.y ** 2) * delta * 100) * speed + add_force
			else:
				position += add_force
				boost += (delta_pos / sqrt(delta_pos.x ** 2 + delta_pos.y ** 2) * delta * 100) * speed
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
			
			$RigidBody2D.move_and_collide(Vector2.ZERO)
			position += -$RigidBody2D.position
			$RigidBody2D.position = Vector2.ZERO
			$RigidBody2D.linear_velocity = Vector2.ZERO
			$RigidBody2D.angular_velocity = 0
			
			if speed < 1 and type == ENEMY_TYPE.MAD:
				speed = min(1, speed + delta / 10)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and body.is_in_group("Player") and not dying:
		var player: Player = body.find_parent("Player")
		player.hit_by_enemy(self)
		dying = true

func kill():
	dying = true
	$RigidBody2D/DeadLight.enabled = true
