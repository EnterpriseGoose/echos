extends Node2D

@export var pin1: PhysicsBody2D
@export var pin2: PhysicsBody2D
@export var chain_start: PhysicsBody2D = pin1
@export var chain_end: PhysicsBody2D = pin2

signal chain_built(chains: Array[PhysicsBody2D])

var single_chain = preload("res://scenes/single_chain.tscn")

func _ready() -> void:
	var ex_chain = single_chain.instantiate()
	var ex_chain_sprite = ex_chain.find_child("Sprite2D")
	var individual_chain_len = (ex_chain_sprite.texture.get_size().y * ex_chain_sprite.scale.y) * .6
	var pin_delta = chain_end.position - chain_start.position
	var chain_len =	sqrt(pin_delta.x ** 2 + pin_delta.y ** 2)
	var chain_num = floor(chain_len / individual_chain_len)
	chain_len = chain_num * individual_chain_len
	var chain_angle = atan2(pin_delta.y, pin_delta.x)
	var unit_vector = Vector2(cos(chain_angle), sin(chain_angle))
	pin_delta = unit_vector * chain_len
	#pin2.position += (chain_start.position + pin_delta) - chain_end.position
	#chain_end.position = chain_start.position + pin_delta
	
	var chains: Array[PhysicsBody2D] = [pin1]
	
	for i in range(chain_num):
		var chain_elem: RigidBody2D = single_chain.instantiate()
		chain_elem.rotation = chain_angle
		chain_elem.position = chain_start.position + unit_vector * individual_chain_len * (i + .5)
		$Chains.add_child(chain_elem)
		chains.append(chain_elem)
	
	chains.append(pin2)
	
	var last_pin: PinJoint2D
	
	for i in range(chain_num + 1):
		var pin_elem = PinJoint2D.new()
		pin_elem.node_a = chains[i].get_path()
		pin_elem.node_b = chains[i + 1].get_path()
		pin_elem.position = chain_start.position + unit_vector * individual_chain_len * i
		pin_elem.softness = .02
		pin_elem.bias = .5
		pin_elem.angular_limit_enabled = false
		pin_elem.angular_limit_lower = -.5
		pin_elem.angular_limit_upper = .5
		$Chains.add_child(pin_elem)
		last_pin = pin_elem
		
	last_pin.bias = 1
	last_pin.softness = .1
	
	chain_built.emit(chains)
