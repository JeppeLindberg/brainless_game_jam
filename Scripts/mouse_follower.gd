extends Node2D


const VIEWPORT_SCALE = 1.0

var screen_pos = Vector2.ZERO

func _input(event):
	if event is InputEventMouse:
		screen_pos = event.position

func _process(_delta: float) -> void:	
	global_position = get_viewport().get_screen_transform() * (get_viewport().get_canvas_transform().affine_inverse() * screen_pos / VIEWPORT_SCALE)
