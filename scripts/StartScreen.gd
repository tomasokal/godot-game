extends Control
# StartScreen

@onready var _play_btn:  Button = $VBox/PlayButton
@onready var _debug_btn: Button = $VBox/DebugButton

func _ready() -> void:
	_play_btn.pressed.connect(_on_play)
	_debug_btn.pressed.connect(_on_debug)

func _on_play() -> void:
	GameManager.go_to_battle()

func _on_debug() -> void:
	# Launch battle with debug console pre-opened
	GameManager.go_to_battle()
