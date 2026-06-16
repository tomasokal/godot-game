extends CanvasLayer
# DebugConsole — toggled with backtick (`), parses text commands.
# Connects to Battle scene via setup().

var _battle: Node = null
var _visible_flag: bool = false

@onready var _panel: PanelContainer = $Panel
@onready var _output: RichTextLabel = $Panel/VBox/Output
@onready var _input: LineEdit       = $Panel/VBox/Input

func _ready() -> void:
	_panel.visible = false
	_input.text_submitted.connect(_on_command_submitted)

func setup(battle_node: Node) -> void:
	_battle = battle_node

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_QUOTELEFT:
			_toggle()
			get_viewport().set_input_as_handled()

func _toggle() -> void:
	_visible_flag = not _visible_flag
	_panel.visible = _visible_flag
	if _visible_flag:
		_input.grab_focus()

func _on_command_submitted(text: String) -> void:
	_input.clear()
	if text.strip_edges().is_empty():
		return
	_print("> " + text)
	var result := _parse(text.strip_edges())
	_print(result)

func _parse(cmd: String) -> String:
	var parts := cmd.split(" ", false)
	if parts.is_empty():
		return ""
	match parts[0].to_lower():
		"help":
			return _help_text()
		"spawn":
			# spawn <unit_type> <col> <row> <faction>
			if parts.size() < 5:
				return "Usage: spawn <unit> <col> <row> <faction>"
			return _battle.debug_spawn(parts[1], parts[2].to_int(), parts[3].to_int(), parts[4])
		"clear":
			return _battle.debug_clear()
		"set_phase":
			if parts.size() < 2:
				return "Usage: set_phase <planning|battle>"
			return _battle.debug_set_phase(parts[1])
		"scenario":
			if parts.size() < 2:
				return "Usage: scenario <id>"
			return _battle.debug_load_scenario(parts[1].to_int())
		"give_card":
			if parts.size() < 2:
				return "Usage: give_card <unit_type>"
			return _battle.debug_give_card(parts[1])
		"list_scenarios":
			return ScenariosScript.list()
		_:
			return "Unknown command: %s  (type 'help')" % parts[0]

func _print(msg: String) -> void:
	_output.append_text(msg + "\n")

func _help_text() -> String:
	return """Commands:
  spawn <unit> <col> <row> <faction>  — e.g. spawn archer 2 3 player
  clear                               — remove all units
  set_phase <planning|battle>
  scenario <id>                       — load preset (1-3)
  list_scenarios
  give_card <archer|lancer|warrior|reinforce>
  help"""
