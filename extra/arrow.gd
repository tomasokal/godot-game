extends Area2D

# Arrow properties
var velocity: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var has_reached_target: bool = false
var speed: float = 600.0
var lifetime: float = 3.0  # Seconds before auto-destroy
var time_alive: float = 0.0

# Trail effect
@onready var trail: Line2D = $Trail

func _ready():
	# Connect to area entered signal for collision detection
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Don't move if we've reached the target
	if has_reached_target:
		return
	
	# Calculate direction to target
	var direction_to_target = global_position.direction_to(target_position)
	var distance_to_target = global_position.distance_to(target_position)
	
	# Calculate movement for this frame
	var movement = speed * delta
	
	# Check if we'll reach or pass the target this frame
	if movement >= distance_to_target:
		# Snap to exact target position
		global_position = target_position
		has_reached_target = true
		velocity = Vector2.ZERO
		print("Arrow reached target")
	else:
		# Continue moving towards target
		velocity = direction_to_target * speed
		position += velocity * delta
		
		# Rotate arrow to face direction of travel
		rotation = velocity.angle()
	
	# Update trail
	update_trail()
	
	# Update lifetime
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func launch(start_pos: Vector2, target_pos: Vector2):
	"""
	Launch arrow from start_pos directly towards target_pos
	Arrow will travel in straight line and stop at target
	"""
	global_position = start_pos
	target_position = target_pos
	has_reached_target = false
	
	# Calculate initial direction and velocity
	var direction = start_pos.direction_to(target_pos)
	velocity = direction * speed
	
	# Set initial rotation
	rotation = velocity.angle()

func update_trail():
	"""Update the trail effect behind the arrow"""
	if trail:
		# Add current position to trail
		trail.add_point(trail.to_local(global_position))
		
		# Limit trail length (keep last 20 points)
		if trail.get_point_count() > 20:
			trail.remove_point(0)

func _on_body_entered(body):
	"""Handle collision with enemies or environment"""
	print("Arrow hit: ", body.name)
	
	# Check if we hit an enemy
	if body.has_method("take_damage"):
		body.take_damage(10)  # Deal damage
	
	# Create impact effect here if desired
	# spawn_impact_effect()
	
	# Destroy arrow on impact
	queue_free()
