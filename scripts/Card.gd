extends Button

@export var suit: String = ""
@export var rank: String = ""
@export var unit_type: String = ""

func _ready():
	var label = get_node("Label")
	label.text = "%s\n%s\n%s" % [suit, rank, unit_type]
	
	# Color code by suit (German deck colors)
	match suit:
		"Acorns":
			modulate = Color(0.6, 0.4, 0.2)  # Brown
		"Hearts":
			modulate = Color(1.0, 0.4, 0.4)  # Red
		"Bells":
			modulate = Color(1.0, 0.85, 0.3)  # Gold/Yellow
		"Leaves":
			modulate = Color(0.4, 0.8, 0.4)  # Green

# Note: Card pressing is now handled by player.gd via signal connection
