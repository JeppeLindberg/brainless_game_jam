extends Node2D

@onready var guys = get_node('/root/main/guys')
@onready var emitter = get_node('emitter')
@export var guy: PackedScene

@export var label: Label

@export var needed_guys = 1
var current_guys = 0
@export var guys_to_emit = 3


func _process(_delta: float) -> void:
	label.text = str(current_guys) + '/' + str(needed_guys)

func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group('Player'):
		if current_guys < needed_guys:
			current_guys += 1
			var new_guys = current_guys
			await body.despawn()

			if new_guys >= needed_guys:
				start_spawning()


func start_spawning():
	for existing_guy in guys.get_children():
		if existing_guy.is_in_group('Player'):
			existing_guy.spawn_point = emitter


	for i in range(guys_to_emit):
		await get_tree().create_timer(0.1).timeout
		var new_guy = guy.instantiate()
		guys.add_child(new_guy)
		new_guy.spawn_point = emitter
		new_guy.respawn()
		await get_tree().create_timer(0.1).timeout
		
