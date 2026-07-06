extends Node2D

@onready var guys = get_node('/root/view/container/viewport/main/guys')
@onready var plant_nodes = get_node('plant_nodes')

@export var label: Label

@export var needed_guys = 1
var current_guys = 0



func _ready() -> void:
	for child in plant_nodes.get_children():
		for collider in child.get_children():
			if collider is CollisionShape2D:
				collider.disabled = true
		child.visible = false;

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
	for child:StaticBody2D in plant_nodes.get_children():
		for collider in child.get_children():
			if collider is CollisionShape2D:
				collider.disabled = false
		child.visible = true;
