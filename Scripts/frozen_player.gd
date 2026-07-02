extends StaticBody2D

@export var spawn_object: PackedScene
@export var freqency_secs = 1.0
@export var min_distance_to_prev_bubble = 300.0

@onready var effects = get_node('/root/main/effects')
@onready var player = get_node('/root/main/player')
@onready var bubbles = get_node('bubbles')

var newest_bubble = null


var progress = 0.0


func _process(delta: float) -> void:
	progress += delta

	var dist = 9999.0
	if newest_bubble != null:
		dist = newest_bubble.global_position.distance_to(global_position)

	if (progress > freqency_secs) and (dist > min_distance_to_prev_bubble) and (global_position.distance_to(player.global_position) > 70.0):
		var new_node = spawn_object.instantiate()
		new_node.global_position = global_position
		effects.add_child(new_node)
		progress = 0.0
		newest_bubble = new_node
