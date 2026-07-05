extends Node2D

@onready var body = get_node('body')
@onready var position_1 = get_node('position_1')
@onready var position_2 = get_node('position_2')

@export var curve: Curve

@export var speed_mult = 0.3



var progress = 0.0

func _process(delta: float) -> void:
	progress += delta * speed_mult
	if progress > curve.max_domain:
		progress -= curve.max_domain

	var weight = curve.sample(progress)

	body.global_position = lerp(position_1.global_position, position_2.global_position, weight)
	body.global_rotation = lerp(position_1.global_rotation, position_2.global_rotation, weight)






