extends Area2D

@onready var base_position = position



func _process(_delta: float) -> void:
	var screen_pos = get_viewport().size / 2.0;
	var screen_mid_world_pos = get_viewport().get_screen_transform() * (get_viewport().get_canvas_transform().affine_inverse() * screen_pos)
	global_position = screen_mid_world_pos + base_position

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('Player'):
		body.die()
