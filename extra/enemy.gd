extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
var player: CharacterBody2D
var is_attacking = false

func _ready():
	# Find the player node more robustly
	player = get_tree().get_first_node_in_group("player")
	
	# If not found by group, try to find by script (assuming player has player.gd attached)
	if not player:
		for node in get_tree().current_scene.get_children():
			if node.has_method("_physics_process") and node.script and "player" in str(node.script.resource_path):
				player = node
				break
	
	# Last resort: find first CharacterBody2D that's not this enemy
	if not player:
		for node in get_tree().get_nodes_in_group("*"):
			if node is CharacterBody2D and node != self:
				player = node
				break
	
	if not player:
		print("Warning: Player not found!")
	
	# Connect to animation finished signal
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta):
	if not player:
		return
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 200
	move_and_slide()
	
	# Handle sprite flipping based on player direction
	handle_sprite_direction()
	
	# Handle animations based on movement and actions
	handle_animations()

func handle_sprite_direction():
	if not player:
		return
	
	var player_pos = player.global_position
	var enemy_pos = global_position
	
	# Flip sprite horizontally based on player direction
	if player_pos.x < enemy_pos.x:
		animated_sprite.flip_h = true  # Face left
	else:
		animated_sprite.flip_h = false  # Face right

func handle_animations():
	# Check if colliding with player (attack trigger)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == player and not is_attacking:
			is_attacking = true
			animated_sprite.play("attack")
			print("Enemy attacking!")
			return
	
	# Handle normal movement animations (when not attacking)
	if not is_attacking:
		if velocity.length() > 0:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")
		else:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")

func _on_animation_finished():
	# Reset attacking state when attack animation finishes
	if animated_sprite.animation == "attack":
		is_attacking = false
		print("Enemy attack animation finished")
		# Immediately switch to appropriate animation
		if velocity.length() > 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
