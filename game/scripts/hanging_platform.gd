extends Node2D
class_name HangingPlatform

@export var platform: RigidBody2D

func push(force: Vector2, pos: Vector2):
	platform.apply_force(force * platform.position.length() / 500, pos - platform.global_position)
	print(platform.global_position - pos)
		
	for chain in $Chain/Chains.get_children():
		if chain is RigidBody2D:
			chain.apply_force(force * chain.position.length())
