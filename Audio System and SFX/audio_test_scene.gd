extends Node

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT:  AudioManager.set_music_state.emit("main_menu")
			KEY_UP:    AudioManager.set_music_state.emit("non_combat")
			KEY_RIGHT: AudioManager.set_music_state.emit("combat")
			KEY_DOWN:  AudioManager.set_music_state.emit("shopping")
			KEY_SPACE: AudioManager.set_music_state.emit("dying")
