extends Area2D

@onready var player = get_node('/root/main/player')

# Define the next scene to load in the inspector
@export var next_spawn_point: Node2D

# Load next level scene when player collide with level finish door.
func _on_body_entered(body):
	if body.is_in_group("Player"):
		player.move_to_new_spawn_point(next_spawn_point)
