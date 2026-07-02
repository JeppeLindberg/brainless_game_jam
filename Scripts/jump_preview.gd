extends Node2D

@onready var mouse_follower = get_node('/root/main/mouse_follower')


func _process(_delta: float) -> void:
	if mouse_follower == null:
		return
	look_at(mouse_follower.global_position)
