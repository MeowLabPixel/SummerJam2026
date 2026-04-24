extends Node

## AudioSettings — Autoload Singleton
## Add to Project Settings > Autoload as "AudioSettings"
##
## Handles volume save/load for all 3 buses.
## Wire your UI sliders directly to the methods below.
##
## CANVAS ITEM (UI) USAGE — connect a HSlider in your menu:
##
##   # In your settings menu script:
##   $SFXSlider.value_changed.connect(AudioSettings.set_sfx_volume)
##   $DialogueSlider.value_changed.connect(AudioSettings.set_dialogue_volume)
##   $MusicSlider.value_changed.connect(AudioSettings.set_music_volume)
##
##   # On menu open, populate sliders with saved values:
##   $SFXSlider.value     = AudioSettings.get_sfx_volume()
##   $DialogueSlider.value = AudioSettings.get_dialogue_volume()
##   $MusicSlider.value   = AudioSettings.get_music_volume()
##
## Sliders should be set to min=0.0, max=1.0, step=0.01

const SAVE_PATH := "user://audio_settings.cfg"
const SECTION   := "audio"

# Bus names — must match AudioServer bus layout
const BUS_MASTER   := "Master"
const BUS_SFX      := "SFX"
const BUS_DIALOGUE := "Dialogue"
const BUS_MUSIC    := "Music"

var _config := ConfigFile.new()

# ---------------------------------------------------------------------------
func _ready() -> void:
	load_settings()

# ---------------------------------------------------------------------------
# VOLUME SETTERS  (0.0 – 1.0 linear, converted to dB internally)
# ---------------------------------------------------------------------------

func set_master_volume(linear: float) -> void:
	_set_bus_volume(BUS_MASTER, linear)
	_config.set_value(SECTION, "master", linear)
	_save()

func set_sfx_volume(linear: float) -> void:
	_set_bus_volume(BUS_SFX, linear)
	_config.set_value(SECTION, "sfx", linear)
	_save()

func set_dialogue_volume(linear: float) -> void:
	_set_bus_volume(BUS_DIALOGUE, linear)
	_config.set_value(SECTION, "dialogue", linear)
	_save()

func set_music_volume(linear: float) -> void:
	_set_bus_volume(BUS_MUSIC, linear)
	_config.set_value(SECTION, "music", linear)
	_save()

# ---------------------------------------------------------------------------
# VOLUME GETTERS  (returns 0.0 – 1.0)
# ---------------------------------------------------------------------------

func get_master_volume()   -> float: return _get_bus_volume(BUS_MASTER)
func get_sfx_volume()      -> float: return _get_bus_volume(BUS_SFX)
func get_dialogue_volume() -> float: return _get_bus_volume(BUS_DIALOGUE)
func get_music_volume()    -> float: return _get_bus_volume(BUS_MUSIC)

# ---------------------------------------------------------------------------
# MUTE TOGGLES
# ---------------------------------------------------------------------------

func set_sfx_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_SFX), muted)

func set_dialogue_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_DIALOGUE), muted)

func set_music_muted(muted: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_MUSIC), muted)

func is_sfx_muted()      -> bool: return AudioServer.is_bus_mute(AudioServer.get_bus_index(BUS_SFX))
func is_dialogue_muted() -> bool: return AudioServer.is_bus_mute(AudioServer.get_bus_index(BUS_DIALOGUE))
func is_music_muted()    -> bool: return AudioServer.is_bus_mute(AudioServer.get_bus_index(BUS_MUSIC))

# ---------------------------------------------------------------------------
# SAVE / LOAD
# ---------------------------------------------------------------------------

func load_settings() -> void:
	var err := _config.load(SAVE_PATH)
	if err != OK:
		# First run — apply defaults
		set_master_volume(1.0)
		set_sfx_volume(0.8)
		set_dialogue_volume(1.0)
		set_music_volume(0.6)
		return

	_set_bus_volume(BUS_MASTER,   _config.get_value(SECTION, "master",   1.0))
	_set_bus_volume(BUS_SFX,      _config.get_value(SECTION, "sfx",      0.8))
	_set_bus_volume(BUS_DIALOGUE, _config.get_value(SECTION, "dialogue", 1.0))
	_set_bus_volume(BUS_MUSIC,    _config.get_value(SECTION, "music",    0.6))
	print("[AudioSettings] Settings loaded from %s" % SAVE_PATH)

func _save() -> void:
	_config.save(SAVE_PATH)

# ---------------------------------------------------------------------------
# INTERNAL
# ---------------------------------------------------------------------------

func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_warning("[AudioSettings] Bus not found: %s" % bus_name)
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(linear, 0.0, 1.0)))

func _get_bus_volume(bus_name: String) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(idx))
