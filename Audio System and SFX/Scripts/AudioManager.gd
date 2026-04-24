extends Node

## AudioManager — Autoload Singleton
## Add to Project > Project Settings > Autoload as "AudioManager"
##
## BASIC USAGE:
##   AudioManager.play_sfx.emit("res://audio/sfx/gunshot.ogg", global_position)
##   AudioManager.play_ui.emit("res://audio/ui/click.ogg")
##   AudioManager.play_dialogue.emit("res://audio/dialogue/npc_hello.ogg", global_position)
##   AudioManager.set_music_state.emit("combat")
##
## RANDOM CATEGORY USAGE:
##   AudioManager.play_random_sfx.emit("attack", global_position)
##   AudioManager.play_random_dialogue.emit("player_hurt", global_position)
##   AudioManager.play_random_ui.emit("button")

# ---------------------------------------------------------------------------
# SIGNALS — emit these from anywhere in your project
# ---------------------------------------------------------------------------

## Play a specific 3D SFX at a world position
signal play_sfx(audio_path: String, world_position: Vector3)

## Play a specific 3D Dialogue/Voiceline at a world position
signal play_dialogue(audio_path: String, world_position: Vector3)

## Play a specific 2D UI sound (no position needed)
signal play_ui(audio_path: String)

## Play a RANDOM 3D SFX from a named category
signal play_random_sfx(category: String, world_position: Vector3)

## Play a RANDOM 3D Dialogue/Voiceline from a named category
signal play_random_dialogue(category: String, world_position: Vector3)

## Play a RANDOM 2D UI sound from a named category
signal play_random_ui(category: String)

## Change music state: "main_menu" | "combat" | "non_combat" | "shopping" | "dying"
signal set_music_state(state: String)

## Stop all audio on a specific bus: "SFX" | "Dialogue" | "Music"
signal stop_bus(bus_name: String)

## Stop all audio everywhere
signal stop_all()

# ---------------------------------------------------------------------------
# SOUND LIBRARY
# Register your sound categories here.
# Key   = category name used in play_random_sfx / play_random_dialogue signals
# Value = array of audio file paths
#
# Add as many categories and files as you need!
# ---------------------------------------------------------------------------
const SFX_LIBRARY: Dictionary = {
	"attack": [
		"res://audio/sfx/attack_01.ogg",
		"res://audio/sfx/attack_02.ogg",
		"res://audio/sfx/attack_03.ogg",
	],
	"footstep": [
		"res://audio/sfx/footstep_01.ogg",
		"res://audio/sfx/footstep_02.ogg",
		"res://audio/sfx/footstep_03.ogg",
	],
	"hit": [
		"res://audio/sfx/hit_01.ogg",
		"res://audio/sfx/hit_02.ogg",
	],
	"death": [
		"res://audio/sfx/death_01.ogg",
		"res://audio/sfx/death_02.ogg",
	],
}

const DIALOGUE_LIBRARY: Dictionary = {
	"player_hurt": [
		"res://audio/dialogue/player_hurt_01.ogg",
		"res://audio/dialogue/player_hurt_02.ogg",
		"res://audio/dialogue/player_hurt_03.ogg",
	],
	"player_death": [
		"res://audio/dialogue/player_death_01.ogg",
		"res://audio/dialogue/player_death_02.ogg",
	],
	"npc_greet": [
		"res://audio/dialogue/npc_greet_01.ogg",
		"res://audio/dialogue/npc_greet_02.ogg",
	],
}

const UI_LIBRARY: Dictionary = {
	"hover": [
	"res://sound/Souls/Unholy UI - Souls (7).wav"
	],
	"accept": ["res://sound/Souls/Unholy UI - Souls (14).wav"
	],
	"start_game":["res://sound/Souls/Unholy UI - Souls (1).wav"],
	"cancle":["res://sound/Souls/Unholy UI - Souls (13).wav"],
	"Title":[
		"res://sound/Songkran Hazard 4lom VA/Title Game/สงกราน-ฮาสาด-สีลม-2.ogg",
		"res://sound/Songkran Hazard 4lom VA/Title Game/สงกราน-ฮาสาด-สีลม.ogg"
		
	]
}

const Leon_SFX_LIBRARY: Dictionary = {
	"attack": [
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Attack2_1.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Attack2_2.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Attack2_3.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Attack3_1.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Attack3_2.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/QA_1.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/QA_3.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/QA_4.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/QA_2.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Ral_attack_2_1.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Ral_attack_2_2.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Ral_attack_2_3.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Ral_attack_2_4.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Real_attack_1.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Real_attack_2.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/Cut/Real_attack_3.wav",
	],
	"grapple": [
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/SFX/Grapple 1.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/SFX/Grapple 3.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/SFX/Grapple Talk.wav"
	],
	"phew": [
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/SFX/phew.wav",
		"res://sound/Songkran Hazard 4lom VA/Rookie Lee/SFX/เห้อ แยก.wav",	
	],
}

const Zombie_Melee_SFX_LIBRARY: Dictionary = {
	"attack": [
	"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/Attack_01.wav", 
	"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/Attack_02.wav",
	"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/Attack_03.wav",
	],
	"talk": [
		"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/handsome_01.wav",
	"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/handsome_02.wav",
	"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/handsome_04.wav",
	"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/handsome_03.wav"
	],
	"hurt": [
		"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/shot_01.wav",
		"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/shot_02.wav",
		"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/shot_03.wav"
	],
	"slapped": [
		"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/Slapped_01.wav",
		"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/Slapped_02.wav",
		"res://sound/Songkran Hazard 4lom VA/Zombie Melee (F)/Slapped_03.wav",
		
	]
}

const Zombie_Range_SFX_LIBRARY: Dictionary ={
	"talk":["res://sound/Songkran Hazard 4lom VA/Zombie Range/ซอมบี้เกรียน ทักทาย.wav"],
	"hurt":["res://sound/Songkran Hazard 4lom VA/Zombie Range/ซอมบี้เกรียน เจ็บ.wav"],
	"attack":[
		"res://sound/Songkran Hazard 4lom VA/Zombie Range/ซอมบี้เกรียน โจมตี.wav",
		"res://sound/Songkran Hazard 4lom VA/Zombie Range/ซอมบี้เกรียน หัวเราะ.wav"
		],	
}

const Anchalee_SFX_LIBRARY: Dictionary ={
	"hurt":[
		"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Hurt_01.wav",
		"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Hurt_02.wav",
		"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Hurt_03.wav",
		"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Hurt_04.wav",	
	],
	"panting":[
	"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Panting_01.wav",
	"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Panting_02.wav"				
	],
	"scared": [
	"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Scared_01.wav",
	"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Scared_02.wav"			
	],
	"surprised": [
	"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Surprised _03.wav",
	"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Surprised_01.wav",
	"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Surprised_02.wav"
									
	],
	"exhausted": [
	"res://sound/Songkran Hazard 4lom VA/Anchalee/SFX/Exhausted.wav"
			
	],
}

const Anchalee_Talk_LIBRARY: Dictionary ={
	"confuse":["res://sound/Songkran Hazard 4lom VA/Anchalee/พูดไปเรื่อย/Confused.wav"],
	"help":["res://sound/Songkran Hazard 4lom VA/Anchalee/พูดไปเรื่อย/Lee_help_01.wav",
	"res://sound/Songkran Hazard 4lom VA/Anchalee/พูดไปเรื่อย/Lee_help_02.wav",
	"res://sound/Songkran Hazard 4lom VA/Anchalee/พูดไปเรื่อย/Lee_help_03.wav"
	],
	"oh_no":["res://sound/Songkran Hazard 4lom VA/Anchalee/พูดไปเรื่อย/Oh_no.wav",
	"res://sound/Songkran Hazard 4lom VA/Anchalee/พูดไปเรื่อย/Oh_no_Lee_01.wav",
	"res://sound/Songkran Hazard 4lom VA/Anchalee/พูดไปเรื่อย/Oh_no_Lee_02.wav"	
	],
	"warning":["res://sound/Songkran Hazard 4lom VA/Anchalee/พูดไปเรื่อย/Warning_01.wav",
	"res://sound/Songkran Hazard 4lom VA/Anchalee/พูดไปเรื่อย/Warning_02.wav"	
	],
	"dad":["res://sound/Songkran Hazard 4lom VA/Anchalee/พูดไปเรื่อย/My_dad_will_hear_about_this.wav"]
}



const Mavin_LIBRARY: Dictionary ={
	"Talk":["res://sound/Songkran Hazard 4lom VA/Mavin/Marvin 1.wav"
]
}

# ---------------------------------------------------------------------------
# BUS NAMES — must match your AudioServer bus layout
# ---------------------------------------------------------------------------
const BUS_SFX      := "SFX"
const BUS_DIALOGUE := "Dialogue"
const BUS_MUSIC    := "Music"

# ---------------------------------------------------------------------------
# POOL SIZES
# ---------------------------------------------------------------------------
const SFX_POOL_SIZE      := 8
const DIALOGUE_POOL_SIZE := 2

# ---------------------------------------------------------------------------
# NODES
# ---------------------------------------------------------------------------
var _sfx_pool:      Array[AudioStreamPlayer3D] = []
var _dialogue_pool: Array[AudioStreamPlayer3D] = []
var _ui_player:     AudioStreamPlayer
var _music_player:  AudioStreamPlayer

var _sfx_pool_idx:      int = 0
var _dialogue_pool_idx: int = 0

# Track last played index per category to avoid same sound twice in a row
var _last_sfx_index:      Dictionary = {}
var _last_dialogue_index: Dictionary = {}

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

func _build_ui_player() -> void:
	_ui_player = AudioStreamPlayer.new()
	_ui_player.bus = BUS_SFX
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
	play_random_sfx.connect(_on_play_random_sfx)
	play_random_dialogue.connect(_on_play_random_dialogue)
	play_random_ui.connect(_on_play_random_ui)
	set_music_state.connect(_on_set_music_state)
	stop_bus.connect(_on_stop_bus)
	stop_all.connect(_on_stop_all)

# ---------------------------------------------------------------------------
# HANDLERS — specific sound
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

# ---------------------------------------------------------------------------
# HANDLERS — random from category
# ---------------------------------------------------------------------------
func _on_play_random_sfx(category: String, world_position: Vector3) -> void:
	var path := _pick_random(SFX_LIBRARY, category, _last_sfx_index)
	if path != "":
		_on_play_sfx(path, world_position)

func _on_play_random_dialogue(category: String, world_position: Vector3) -> void:
	var path := _pick_random(DIALOGUE_LIBRARY, category, _last_dialogue_index)
	if path != "":
		_on_play_dialogue(path, world_position)

func _on_play_random_ui(category: String) -> void:
	var path := _pick_random(UI_LIBRARY, category, {})
	if path != "":
		_on_play_ui(path)

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

## Picks a random entry from a library category.
## Avoids repeating the same sound twice in a row (if category has 2+ sounds).
func _pick_random(library: Dictionary, category: String, last_index: Dictionary) -> String:
	if not library.has(category):
		push_warning("[AudioManager] Unknown audio category: '%s'" % category)
		return ""

	var sounds: Array = library[category]
	if sounds.is_empty():
		push_warning("[AudioManager] Category '%s' has no sounds registered." % category)
		return ""

	if sounds.size() == 1:
		return sounds[0]

	# Avoid same sound as last time
	var last: int = last_index.get(category, -1)
	var idx: int = randi() % sounds.size()
	var attempts := 0
	while idx == last and attempts < 10:
		idx = randi() % sounds.size()
		attempts += 1

	last_index[category] = idx
	return sounds[idx]

func _load_stream(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		push_warning("[AudioManager] Audio file not found: %s" % path)
		return null
	return load(path) as AudioStream

## Get the AudioStreamPlayer used for music
func get_music_player() -> AudioStreamPlayer:
	return _music_player
