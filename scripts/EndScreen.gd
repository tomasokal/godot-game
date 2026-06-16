extends Control
# EndScreen

@onready var _result_label: Label  = $VBox/ResultLabel
@onready var _play_again:   Button = $VBox/PlayAgainButton
@onready var _menu_btn:     Button = $VBox/MenuButton

func _ready() -> void:
	var winner := GameManager.winner
	match winner:
		"player": _result_label.text = "Victory!"
		"enemy":  _result_label.text = "Defeat!"
		"draw":   _result_label.text = "Draw!"
		_:        _result_label.text = "Battle Over"
	_play_again.pressed.connect(func(): GameManager.go_to_battle())
	_menu_btn.pressed.connect(func(): GameManager.go_to_start_screen())
