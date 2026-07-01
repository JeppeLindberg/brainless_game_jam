extends Node2D


const VIEWPORT_SCALE = 1.0

func _input(event):
	if event is InputEventMouse:
		global_position = get_viewport().get_screen_transform() * (get_viewport().get_canvas_transform().affine_inverse() * event.position / VIEWPORT_SCALE)
