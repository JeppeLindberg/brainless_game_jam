extends CharacterBody2D

# --------- VARIABLES ---------- #

@export_category("Player Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 400
@export var jump_force : float = 550
@export var gravity : float = 15
@export var camera: Camera2D

var jump_charge = 0.0

# @export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)
# @export var double_jump : = false

var is_grounded : bool = false

@onready var player_sprite = get_node('sprite')
@onready var spawn_point = get_node('/root/main/stage/spawn_point_1')
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles
@onready var mouse_follower = get_node('/root/main/mouse_follower')
# @onready var frozen_players = get_node('../frozen_players')
@onready var state_label = get_node('state')
@onready var jump_preview = get_node('jump_preview')

@export_enum('platforming', 'climbing', 'preparing_jump', 'jumping_no_climb', 'jumping_yes_climb') var state = 'platforming'

@export var frozen_player: PackedScene


# func _ready() -> void:
# 	global_position = spawn_point.global_position

func _process(delta):
	# Calling functions
	if spawn_frozen_player():
		return

	handle_jumping()
	charge_jump(delta)
	movement()
	player_animations()
	flip_player()

	if state == 'jumping_no_climb' and len(climbables) == 0:
		state = 'jumping_yes_climb'
	
	if (state in ['jumping_no_climb', 'jumping_yes_climb']) and is_on_floor():
		if len(climbables) == 0:
			go_to_state('platforming')
		else:
			go_to_state('climbing')
	
	if state in ['platforming'] and !is_on_floor():
		go_to_state('jumping_yes_climb')

	state_label.text = state

	jump_preview.visible = state == 'preparing_jump'

func spawn_frozen_player():
	if Input.is_action_just_pressed('Freeze'):
		var new_node = frozen_player.instantiate()
		var new_sprite:AnimatedSprite2D = new_node.get_node('sprite')
		# frozen_players.add_child(new_node)
		new_sprite.animation = player_sprite.animation
		new_sprite.frame_progress = player_sprite.frame_progress
		new_sprite.global_scale = player_sprite.global_scale
		new_node.global_position = global_position
		new_node.global_scale = global_scale
		respawn()
		return true
	else:
		return false

# <-- Player Movement Code -->
func movement():
	
	# var input_x = Input.get_axis("Left", "Right")
	# var input_y = Input.get_axis("Up", "Down")

	var input_x = 0.0
	var input_y = 0.0

	if Input.is_action_pressed('Move'):
		var dist_x = mouse_follower.global_position.x - global_position.x
		var dist_y = mouse_follower.global_position.y - global_position.y
		var _sign_x = 1.0
		if dist_x < 0:
			_sign_x = -1.0
		var _sign_y = 1.0
		if dist_y < 0:
			_sign_y = -1.0
		dist_x = abs(dist_x)
		dist_y = abs(dist_y)
		var weight_x = (300 - dist_x) / 300.0
		weight_x = clampf(weight_x, 0.1, 100.0)
		input_x = weight_x * _sign_x
		var weight_y = (300 - dist_y) / 300.0
		weight_y = clampf(weight_y, 0.1, 100.0)
		input_y = weight_y * _sign_y

		if dist_x < 10.0:
			input_x = 0
		if dist_y < 10.0:
			input_y = 0

	if state in ['jumping_no_climb', 'jumping_yes_climb', 'platforming']:
		# Gravity
		velocity = Vector2(input_x * move_speed, velocity.y)

		if !is_on_floor():
			velocity.y += gravity
			velocity.x *= 0.5

	
	if state == 'climbing':
		velocity = Vector2(input_x * move_speed * 0.8, input_y * move_speed )
	
	if state == 'preparing_jump':			
		velocity = Vector2(0.0, 0.0)			
	
	move_and_slide()

func handle_jumping():
	if state in ['platforming', 'climbing'] and Input.is_action_just_pressed("Jump"):
		go_to_state('jumping_no_climb')

func charge_jump(delta):
	if state == 'preparing_jump':
		jump_charge += delta


# Player jump
func jump():
	# var direction_weighted = Vector2.UP
	# velocity = direction_weighted * jump_force #* jump_charge

	var direction_weighted = Vector2.UP
	var x_dist =abs(global_position.x - mouse_follower.global_position.x)
	var mult = (300 - x_dist) / 300.0
	
	velocity = direction_weighted * jump_force * clampf(mult, 0.4, 100.0)

	jump_tween()

# Handle Player Animations
func player_animations():
	particle_trails.emitting = false
	
	if state == 'climbing':
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			player_sprite.play("climb", 1.5)
		else:
			player_sprite.play("climb_idle")

		return

	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			player_sprite.play("walk", 1.5)
		else:
			player_sprite.play("idle")
	else:
		player_sprite.play("jump")

# Flip player sprite based on X velocity
func flip_player():
	if velocity.x < 0: 
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

func move_to_new_spawn_point(new_spawn_point):
	spawn_point = new_spawn_point
	teleport_tween()

func despawn():
	var tween = create_tween()
	tween.tween_property(player_sprite, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	queue_free()

# Tween Animations
func die():
	death_particles.emitting = true
	var tween = create_tween()
	tween.tween_property(player_sprite, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	death_particles.emitting = false
	respawn()

func teleport_tween():
	var tween = create_tween()
	tween.tween_property(player_sprite, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	global_position = spawn_point.global_position
	camera.position_smoothing_enabled = false
	camera.drag_horizontal_enabled = false
	camera.drag_vertical_enabled = false
	await get_tree().process_frame
	camera.position_smoothing_enabled = true
	camera.drag_horizontal_enabled = true
	camera.drag_vertical_enabled = true
	respawn()

func respawn():
	go_to_state('platforming')
	velocity = Vector2.ZERO
	global_position = spawn_point.global_position
	respawn_tween()

func respawn_tween():
	player_sprite.scale = Vector2.ZERO
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(player_sprite, "scale", Vector2.ONE, 0.15) 

func jump_tween():
	var tween = create_tween()
	tween.tween_property(player_sprite, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(player_sprite, "scale", Vector2.ONE, 0.1)

func go_to_state(new_state):
	if state == new_state:
		return

	if new_state == 'climbing':
		velocity = Vector2.ZERO
	if new_state == 'preparing_jump':
		velocity = Vector2.ZERO
		jump_charge = 0.0
	if new_state == 'jumping_no_climb':
		jump()

	state = new_state

var climbables = []

func add_to_climbable_touching(new_body):
	if not new_body in climbables:
		climbables.append(new_body)

	if len(climbables) > 0 and state != 'jumping_no_climb':
		go_to_state('climbing')

func remove_from_climbable_touching(old_body):
	if old_body in climbables:
		climbables.erase(old_body)

	if len(climbables) == 0 and (not state in ['jumping_no_climb', 'jumping_yes_climb']):
		go_to_state('platforming')


# --------- SIGNALS ---------- #

func _on_collision_body_entered(body):
	if body.is_in_group("Ground"):
		if len(climbables) == 0:
			go_to_state('platforming')
	if body.is_in_group("Traps"):
		die()


func _on_collision_body_exited(_body: Node2D) -> void:
	pass


func _on_climbable_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group('Climbable'):
		add_to_climbable_touching(body)


func _on_climbable_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group('Climbable'):
		remove_from_climbable_touching(body)
