extends CharacterBody2D

# --------- VARIABLES ---------- #

@export_category("Player Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 400
@export var jump_force : float = 600
@export var gravity : float = 30

var jump_charge = 0.0

# @export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)
# @export var double_jump : = false

var is_grounded : bool = false

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles
@onready var mouse_follower = get_node('../mouse_follower')
@onready var frozen_players = get_node('../frozen_players')
@onready var state_label = get_node('state')

@export_enum('platforming', 'climbing', 'preparing_jump', 'jumping_no_climb', 'jumping_yes_climb') var state = 'platforming'

@export var frozen_player: PackedScene


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

	state_label.text = state

func spawn_frozen_player():
	if Input.is_action_just_pressed('Freeze'):
		var new_node = frozen_player.instantiate()
		var new_sprite:AnimatedSprite2D = new_node.get_node('sprite')
		frozen_players.add_child(new_node)
		new_sprite.animation = player_sprite.animation
		new_sprite.frame_progress = player_sprite.frame_progress
		new_node.global_position = global_position
		new_node.global_scale = global_scale
		respawn()
		return true
	else:
		return false

# <-- Player Movement Code -->
func movement():
	
	var input_x = Input.get_axis("Left", "Right")
	var input_y = Input.get_axis("Up", "Down")

	if state == 'platforming':
		# Gravity
		if !is_on_floor():
			velocity.y += gravity

		velocity = Vector2(input_x * move_speed, velocity.y)
	
	if state == 'climbing':
		velocity = Vector2(input_x * move_speed * 0.8, input_y * move_speed * 0.8)
	
	if state == 'preparing_jump':
		# Gravity
		if !is_on_floor():
			velocity.y += gravity * 0.02	
			
		velocity = Vector2(0.0, velocity.y)
	
	if state in ['jumping_no_climb', 'jumping_yes_climb']:
		# Gravity
		if !is_on_floor():
			velocity.y += gravity * 0.2	
			
	
	move_and_slide()

func handle_jumping():
	if state in ['platforming', 'climbing'] and Input.is_action_just_pressed("Jump"):
		go_to_state('preparing_jump')
	
	if state == 'preparing_jump' and Input.is_action_just_released('Jump'):
		go_to_state('jumping_no_climb')

func charge_jump(delta):
	if state == 'preparing_jump':
		jump_charge += delta


# Player jump
func jump():
	print(mouse_follower.position)
	velocity = (mouse_follower.global_position - global_position).normalized() * jump_force * jump_charge
	jump_tween()

# Handle Player Animations
func player_animations():
	particle_trails.emitting = false
	
	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			player_sprite.play("Walk", 1.5)
		else:
			player_sprite.play("Idle")
	else:
		player_sprite.play("Jump")

# Flip player sprite based on X velocity
func flip_player():
	if velocity.x < 0: 
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

# Tween Animations
func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	global_position = spawn_point.global_position
	await get_tree().create_timer(0.3).timeout
	respawn_tween()

func respawn():
	go_to_state('platforming')
	velocity = Vector2.ZERO
	global_position = spawn_point.global_position

func respawn_tween():
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

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
		death_particles.emitting = true
		death_tween()


func _on_collision_body_exited(_body: Node2D) -> void:
	pass


func _on_climbable_detector_body_entered(body: Node2D) -> void:
	add_to_climbable_touching(body)


func _on_climbable_detector_body_exited(body: Node2D) -> void:
	remove_from_climbable_touching(body)
