extends Node2D

@onready var body = get_node('body')
@onready var on_position = get_node('on_position')
@onready var off_position = get_node('off_position')


var turned_on = false

var progress = 0.0


func _ready() -> void:
	off()

func _process(delta: float) -> void:
	if turned_on:
		progress += delta
		if progress > 1.0:
			progress = 1.0
	
	if not turned_on:
		progress -= delta
		if progress < 0.0:
			progress = 0.0

	body.global_position = lerp(off_position.global_position, on_position.global_position, progress)
	body.global_rotation = lerp(off_position.global_rotation, on_position.global_rotation, progress)

func on():
	turned_on = true

func off():
	turned_on = false




