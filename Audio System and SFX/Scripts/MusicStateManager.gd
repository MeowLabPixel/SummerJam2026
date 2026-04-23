extends Node

## MusicStateManager — Autoload Singleton
## Add to Project Settings > Autoload as "MusicStateManager"
## Depends on AudioManager being loaded first (place BELOW AudioManager in autoload list)
##
## Uses AudioStreamInteractive for seamless crossfading between music states.
##
## MUSIC STATES:
##   "main_menu"   — main menu theme
##   "non_combat"  — exploration / calm
##   "combat"      — action / tension
##   "shopping"    — safe zone / shop
##   "dying"       — low health / dread
##
## HOW TO USE AudioStreamInteractive in the Godot editor:
##   1. Create a new AudioStreamInteractive resource
##   2. Add clips for each state (main_menu, non_combat, combat, shopping, dying)
##   3. Set transitions between clips with fade times in the Transitions tab
##   4. Assign the resource to `music_stream` export below

# ---------------------------------------------------------------------------
# EXPORTS — assign your AudioStreamInteractive resource in the Inspector
# ---------------------------------------------------------------------------
@export var music_stream: AudioStreamInteractive

# State name → clip index inside your AudioStreamInteractive resource
# Adjust clip indices to match the order you added them in the editor
const STATE_CLIP_INDEX := {
	"main_menu":  0,
	"non_combat": 1,
	"combat":     2,
	"shopping":   3,
	"dying":      4,
}

const DEFAULT_STATE       := "main_menu"
const CROSSFADE_TIME_SEC  := 1.5  # seconds — also set this in AudioStreamInteractive transitions

var _current_state: String = ""
var _music_player: AudioStreamPlayer

# ---------------------------------------------------------------------------
func _ready() -> void:
	# Wait one frame for AudioManager to finish _ready()
	await get_tree().process_frame
	_music_player = AudioManager.get_music_player()

	if music_stream == null:
		push_warning("[MusicStateManager] No AudioStreamInteractive assigned! " +
			"Create one in the editor and assign it to MusicStateManager.music_stream")
		return

	_music_player.stream = music_stream
	_music_player.play()
	transition_to(DEFAULT_STATE)

# ---------------------------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------------------------

## Transition to a named music state. Called by AudioManager when
## set_music_state signal is emitted from anywhere in the project.
func transition_to(state: String) -> void:
	if state == _current_state:
		return

	if not STATE_CLIP_INDEX.has(state):
		push_warning("[MusicStateManager] Unknown music state: '%s'. Valid: %s" % [
			state, str(STATE_CLIP_INDEX.keys())
		])
		return

	if music_stream == null:
		push_warning("[MusicStateManager] Cannot transition — no music stream assigned.")
		return

	var clip_idx: int = STATE_CLIP_INDEX[state]
	_current_state = state

	# AudioStreamInteractivePlayback handles the crossfade automatically
	# based on transitions defined in the AudioStreamInteractive resource
	var playback := _music_player.get_stream_playback()
	if playback and playback.has_method("switch_to_clip"):
		playback.switch_to_clip(clip_idx)
		print("[MusicStateManager] → %s (clip %d)" % [state, clip_idx])
	else:
		push_warning("[MusicStateManager] No active playback — restarting player.")
		_music_player.play()

## Get current state name
func get_current_state() -> String:
	return _current_state
