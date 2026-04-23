extends Node

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F6: AudioManager.set_music_state.emit("main_menu")
			KEY_F7: AudioManager.set_music_state.emit("non_combat")
			KEY_F8: AudioManager.set_music_state.emit("combat")
			KEY_F9: AudioManager.set_music_state.emit("shopping")
			KEY_F10: AudioManager.set_music_state.emit("dying")
