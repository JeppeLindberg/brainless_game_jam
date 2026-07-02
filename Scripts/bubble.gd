extends AnimatableBody2D

@export var speed = 50.0

@onready var stand_still_area: Area2D = get_node('stand_still_area')
@onready var pop_area: Area2D = get_node('pop_area')
@onready var debug = get_node('debug')



func _physics_process(delta: float) -> void:
	var touching_player = false
	var touching_pop_object = false

	debug.text = str(pop_area.connecting_bodies)

	for body in stand_still_area.connecting_bodies:
		if body.is_in_group('Player'):
			touching_player = true

	for body in pop_area.connecting_bodies:
		if body.is_in_group('Ground') or body.is_in_group('Player') or (body.is_in_group('Bubble') and body != self):
			touching_pop_object = true
	
	if not touching_player:
		global_position += Vector2.UP * speed * delta

	if touching_pop_object:
		queue_free()
