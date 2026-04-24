extends Control

## AudioSettingsMenu.gd — Example Canvas Item (UI) settings panel
##
## Attach this to a Control node in your Main Menu or Pause Menu scene.
## The scene should have HSliders and CheckButtons as shown below.
##
## Suggested scene tree:
##   AudioSettingsMenu (Control)
##   ├── MasterSlider    (HSlider)
##   ├── SFXSlider       (HSlider)
##   ├── DialogueSlider  (HSlider)
##   ├── MusicSlider     (HSlider)
##   ├── SFXMuteBtn      (CheckButton)
##   ├── DialogueMuteBtn (CheckButton)
##   └── MusicMuteBtn    (CheckButton)

@onready var master_slider:    HSlider     = $MasterSlider
@onready var sfx_slider:       HSlider     = $SFXSlider
@onready var dialogue_slider:  HSlider     = $DialogueSlider
@onready var music_slider:     HSlider     = $MusicSlider
@onready var sfx_mute_btn:     CheckButton = $SFXMuteBtn
@onready var dialogue_mute_btn:CheckButton = $DialogueMuteBtn
@onready var music_mute_btn:   CheckButton = $MusicMuteBtn

func _ready() -> void:
	# Populate sliders with current saved values
	master_slider.value   = AudioSettings.get_master_volume()
	sfx_slider.value      = AudioSettings.get_sfx_volume()
	dialogue_slider.value = AudioSettings.get_dialogue_volume()
	music_slider.value    = AudioSettings.get_music_volume()

	sfx_mute_btn.button_pressed      = AudioSettings.is_sfx_muted()
	dialogue_mute_btn.button_pressed  = AudioSettings.is_dialogue_muted()
	music_mute_btn.button_pressed     = AudioSettings.is_music_muted()

	# Connect sliders → AudioSettings
	master_slider.value_changed.connect(AudioSettings.set_master_volume)
	sfx_slider.value_changed.connect(AudioSettings.set_sfx_volume)
	dialogue_slider.value_changed.connect(AudioSettings.set_dialogue_volume)
	music_slider.value_changed.connect(AudioSettings.set_music_volume)

	# Connect mute buttons
	sfx_mute_btn.toggled.connect(AudioSettings.set_sfx_muted)
	dialogue_mute_btn.toggled.connect(AudioSettings.set_dialogue_muted)
	music_mute_btn.toggled.connect(AudioSettings.set_music_muted)

	# Play a UI click on slider interaction (optional, nice feedback)
	sfx_slider.drag_ended.connect(func(_changed): AudioManager.play_ui.emit("res://audio/ui/slider_tick.ogg"))
