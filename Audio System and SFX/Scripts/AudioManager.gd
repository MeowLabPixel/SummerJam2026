extends Node

## AudioManager — Autoload Singleton
## Add to Project > Project Settings > Autoload as "AudioManager"
##
## OTHER SCRIPTS just emit signals — example:
##   AudioManager.play_sfx.emit("res://audio/sfx/gunshot.ogg", global_position)
##   AudioManager.play_ui.emit("res://audio/ui/click.ogg")
##   AudioManager.play_dialogue.emit("res://audio/dialogue/npc_hello.ogg", global_position)
##   AudioManager.set_music_state.emit("combat")

# ---------------------------------------------------------------------------
# SIGNALS — emit these from anywhere in your project
# ---------------------------------------------------------------------------

## Play a 3D in-world SFX at a world position
signal play_sfx(audio_path: String, world_position: Vector3)

## Play a 3D in-world Dialogue / Voiceline at a world position
signal play_dialogue(audio_path: String, world_position: Vector3)

## Play a 2D UI / Menu sound (no position needed)
signal play_ui(audio_path: String)

## Change music state: "main_menu" | "combat" | "non_combat" | "shopping" | "dying"
signal set_music_state(state: String)

## Stop all audio on a specific bus: "SFX" | "Dialogue" | "Music"
signal stop_bus(bus_name: String)

## Stop all audio everywhere
signal stop_all()

# ---------------------------------------------------------------------------
# BUS INDICES — must match your AudioServer bus layout
# Edit Project > Project Settings > Audio > Buses to match these names:
#   Bus 0: Master
#   Bus 1: SFX
#   Bus 2: Dialogue
#   Bus 3: Music
# ---------------------------------------------------------------------------
const BUS_SFX      := "SFX"
const BUS_DIALOGUE := "Dialogue"
const BUS_MUSIC    := "Music"

# ---------------------------------------------------------------------------
# POOL SIZES — how many simultaneous sounds per category
# ---------------------------------------------------------------------------
const SFX_POOL_SIZE      := 8
const DIALOGUE_POOL_SIZE := 3

# ---------------------------------------------------------------------------
# NODES
# ---------------------------------------------------------------------------
var _sfx_pool:      Array[AudioStreamPlayer3D] = []
var _dialogue_pool: Array[AudioStreamPlayer3D] = []
var _ui_player:     AudioStreamPlayer
var _music_player:  AudioStreamPlayer  # plays AudioStreamInteractive

var _sfx_pool_idx:      int = 0
var _dialogue_pool_idx: int = 0

# ---------------------------------------------------------------------------
# READY
# ---------------------------------------------------------------------------
func _ready() -> void:
	_build_sfx_pool()
	_build_dialogue_pool()
	_build_ui_player()
	_build_music_player()
	_connect_signals()
	print("[AudioManager] Ready. Buses: SFX=%d  Dialogue=%d  Music=%d" % [
		AudioServer.get_bus_index(BUS_SFX),
		AudioServer.get_bus_index(BUS_DIALOGUE),
		AudioServer.get_bus_index(BUS_MUSIC)
	])

# ---------------------------------------------------------------------------
# POOL BUILDERS
# ---------------------------------------------------------------------------
func _build_sfx_pool() -> void:
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer3D.new()
		p.bus = BUS_SFX
		p.name = "SFX_%d" % i
		add_child(p)
		_sfx_pool.append(p)

func _build_dialogue_pool() -> void:
	for i in DIALOGUE_POOL_SIZE:
		var p := AudioStreamPlayer3D.new()
		p.bus = BUS_DIALOGUE
		p.name = "Dialogue_%d" % i
		add_child(p)
		_dialogue_pool.append(p)
		
const DIALOGUE_LIBRARY: Dictionary = {
	
	"Cutscene1Taxi": [
		"res://Audio System and SFX/Cutscene/Cutscene1Taxi.MP3", 
	],
	"Cutscene1End": [
		"res://Audio System and SFX/Cutscene/Cutscene1end.wav", 
	],
	
	"player_hurt": [
		"res://audio/dialogue/player_hurt_01.ogg",  # ← your actual file paths
		"res://audio/dialogue/player_hurt_02.ogg",
		"res://audio/dialogue/player_hurt_03.ogg",
	],

	"leon_talk": [
		"res://audio/dialogue/leon_line_01.ogg",
		"res://audio/dialogue/leon_line_02.ogg",
	],
	"ashley_greet": [
		"res://audio/dialogue/ashley_hello.ogg",
	],
}

func _build_ui_player() -> void:
	_ui_player = AudioStreamPlayer.new()
	_ui_player.bus = "UI"   # UI sounds route through SFX bus
	_ui_player.name = "UIPlayer"
	add_child(_ui_player)

func _build_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_MUSIC
	_music_player.name = "MusicPlayer"
	add_child(_music_player)

# ---------------------------------------------------------------------------
# SIGNAL CONNECTIONS
# ---------------------------------------------------------------------------
func _connect_signals() -> void:
	play_sfx.connect(_on_play_sfx)
	play_dialogue.connect(_on_play_dialogue)
	play_ui.connect(_on_play_ui)
	set_music_state.connect(_on_set_music_state)
	stop_bus.connect(_on_stop_bus)
	stop_all.connect(_on_stop_all)

# ---------------------------------------------------------------------------
# HANDLERS
# ---------------------------------------------------------------------------
func _on_play_sfx(audio_path: String, world_position: Vector3) -> void:
	var stream := _load_stream(audio_path)
	if stream == null:
		return
	var player := _sfx_pool[_sfx_pool_idx % SFX_POOL_SIZE]
	_sfx_pool_idx += 1
	player.stream = stream
	player.global_position = world_position
	player.play()

func _on_play_dialogue(audio_path: String, world_position: Vector3) -> void:
	var stream := _load_stream(audio_path)
	if stream == null:
		return
	# Stop previous dialogue to avoid overlap
	var player := _dialogue_pool[_dialogue_pool_idx % DIALOGUE_POOL_SIZE]
	_dialogue_pool_idx += 1
	player.stop()
	player.stream = stream
	player.global_position = world_position
	player.play()

func _on_play_ui(audio_path: String) -> void:
	var stream := _load_stream(audio_path)
	if stream == null:
		return
	_ui_player.stream = stream
	_ui_player.play()

func _on_set_music_state(state: String) -> void:
	MusicStateManager.transition_to(state)

func _on_stop_bus(bus_name: String) -> void:
	match bus_name:
		BUS_SFX:
			for p in _sfx_pool:
				p.stop()
		BUS_DIALOGUE:
			for p in _dialogue_pool:
				p.stop()
		BUS_MUSIC:
			_music_player.stop()

func _on_stop_all() -> void:
	_on_stop_bus(BUS_SFX)
	_on_stop_bus(BUS_DIALOGUE)
	_on_stop_bus(BUS_MUSIC)
	_ui_player.stop()

# ---------------------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------------------
func _load_stream(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		push_warning("[AudioManager] Audio file not found: %s" % path)
		return null
	return load(path) as AudioStream

## Get the AudioStreamPlayer used for music (so MusicStateManager can control it)
func get_music_player() -> AudioStreamPlayer:
	return _music_player
