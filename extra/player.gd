extends CharacterBody2D

# Preload arrow scene
const ARROW_SCENE = preload("res://scenes/arrow.tscn")

@onready var animated_sprite = $AnimatedSprite2D
var is_attacking = false

func _ready():
	# Connect to animation finished signal
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 400
	move_and_slide()
	
	# Handle sprite rotation/facing direction
	handle_sprite_direction()
	
	# Handle animations based on movement and actions
	handle_animations()

func handle_sprite_direction():
	var mouse_pos = get_global_mouse_position()
	var player_pos = global_position
	
	# Flip sprite horizontally based on mouse direction
	if mouse_pos.x < player_pos.x:
		animated_sprite.flip_h = true  # Face left
	else:
		animated_sprite.flip_h = false # Face right

func handle_animations():
	# Check if shooting with "shoot" action
	if Input.is_action_just_pressed("shoot") and not is_attacking:
		is_attacking = true
		animated_sprite.play("attack")
		shoot_arrow()  # Spawn arrow projectile
		print("Playing attack animation")
	# Handle normal movement animations (when not attacking)
	elif not is_attacking:
		if velocity.length() > 0:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")
		else:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")

func shoot_arrow():
	"""Spawn and launch an arrow towards mouse position"""
	var arrow = ARROW_SCENE.instantiate()
	
	# Add arrow to the scene tree (as sibling of player)
	get_parent().add_child(arrow)
	
	# Get spawn position (slightly in front of player)
	var spawn_offset = Vector2(30, 0)  # 30 pixels in front
	if animated_sprite.flip_h:
		spawn_offset.x *= -1  # Flip if facing left
	
	var spawn_pos = global_position + spawn_offset
	var target_pos = get_global_mouse_position()
	
	# Launch the arrow directly to target (no arc)
	arrow.launch(spawn_pos, target_pos)

func _on_animation_finished():
	# Reset attacking state when attack animation finishes
	if animated_sprite.animation == "attack":
		is_attacking = false
		print("Attack animation finished")
		# Immediately switch to appropriate animation
		if velocity.length() > 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
