extends Area2D

var connecting_bodies = []


func _on_body_exited(body: Node2D) -> void:
	connecting_bodies.erase(body)

func _on_body_entered(body: Node2D) -> void:
	if not body in connecting_bodies:
		connecting_bodies.append(body)
