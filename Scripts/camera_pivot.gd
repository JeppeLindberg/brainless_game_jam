extends Node2D


@onready var mouse_follower = get_node('/root/view/container/viewport/main/mouse_follower')
@onready var guys = get_node('/root/view/container/viewport/main/guys')


func _process(_delta: float) -> void:
	var dist = 99999.0
	var target_node = null
	for child in guys.get_children():
		var mouse_to_guy = mouse_follower.global_position.distance_to(child.global_position)
		if mouse_to_guy < dist:
			target_node = child
			dist = mouse_to_guy
	
	if target_node != null:
		global_position = target_node.global_position
