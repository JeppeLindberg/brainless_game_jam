extends Area2D

var guys_in_collider = []

signal button_down()
signal button_up()


func _on_body_entered(body: Node2D) -> void:
	var prev_len = len(guys_in_collider)

	if body.is_in_group('Player'):
		if not body in guys_in_collider:
			guys_in_collider.append(body)

	var post_len = len(guys_in_collider)

	if prev_len == 0 and post_len != 0:
		emit_signal('button_down')


func _on_body_exited(body: Node2D) -> void:
	var prev_len = len(guys_in_collider)

	if body.is_in_group('Player'):
		guys_in_collider.erase(body)

	var post_len = len(guys_in_collider)

	if prev_len != 0 and post_len == 0:
		emit_signal('button_up')
