extends Node

# ─── Game Phase ───────────────────────────────────────────────────────────────
enum Phase { START_SCREEN, PLANNING, BATTLE, END_SCREEN }

var current_phase: Phase = Phase.START_SCREEN
var winner: String = ""  # "player" or "enemy"

# ─── Scene paths ──────────────────────────────────────────────────────────────
const START_SCREEN_SCENE := "res://scenes/ui/StartScreen.tscn"
const BATTLE_SCENE       := "res://scenes/Battle.tscn"
const END_SCREEN_SCENE   := "res://scenes/ui/EndScreen.tscn"

# ─── Signals ──────────────────────────────────────────────────────────────────
signal phase_changed(new_phase: Phase)

func go_to_start_screen() -> void:
	current_phase = Phase.START_SCREEN
	phase_changed.emit(current_phase)
	get_tree().change_scene_to_file(START_SCREEN_SCENE)

func go_to_battle() -> void:
	current_phase = Phase.PLANNING
	phase_changed.emit(current_phase)
	get_tree().change_scene_to_file(BATTLE_SCENE)

func go_to_end_screen(winning_faction: String) -> void:
	winner = winning_faction
	current_phase = Phase.END_SCREEN
	phase_changed.emit(current_phase)
	get_tree().change_scene_to_file(END_SCREEN_SCENE)

func set_phase(p: Phase) -> void:
	current_phase = p
	phase_changed.emit(p)
