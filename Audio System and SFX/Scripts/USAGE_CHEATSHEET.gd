# ============================================================
#  AUDIO SYSTEM — CHEATSHEET FOR PROGRAMMERS
#  You never need to touch AudioManager, MusicStateManager,
#  or AudioSettings directly. Just emit signals.
# ============================================================

# ────────────────────────────────────────────────────────────
# PLAYING SFX  (3D, positioned in world)
# ────────────────────────────────────────────────────────────

# From any Node3D (e.g. a gun, enemy, door):
AudioManager.play_sfx.emit("res://audio/sfx/gunshot.ogg", global_position)
AudioManager.play_sfx.emit("res://audio/sfx/footstep.ogg", global_position)

# ────────────────────────────────────────────────────────────
# PLAYING DIALOGUE / VOICELINES  (3D, positioned in world)
# ────────────────────────────────────────────────────────────

# From an NPC or player:
AudioManager.play_dialogue.emit("res://audio/dialogue/npc_hello.ogg", global_position)
AudioManager.play_dialogue.emit("res://audio/dialogue/player_pain.ogg", global_position)

# ────────────────────────────────────────────────────────────
# PLAYING UI SOUNDS  (2D, no position)
# ────────────────────────────────────────────────────────────

# From any menu button or UI element:
AudioManager.play_ui.emit("res://audio/ui/button_click.ogg")
AudioManager.play_ui.emit("res://audio/ui/menu_open.ogg")

# ────────────────────────────────────────────────────────────
# MUSIC STATE TRANSITIONS  (crossfade via AudioStreamInteractive)
# ────────────────────────────────────────────────────────────

# Valid states: "main_menu" | "non_combat" | "combat" | "shopping" | "dying"

AudioManager.set_music_state.emit("main_menu")   # on main menu load
AudioManager.set_music_state.emit("non_combat")  # on level start / calm
AudioManager.set_music_state.emit("combat")      # on enemy detection
AudioManager.set_music_state.emit("shopping")    # on shop open
AudioManager.set_music_state.emit("dying")       # on low HP threshold

# Example: trigger combat music when enemy detects player
func _on_enemy_detected() -> void:
	AudioManager.set_music_state.emit("combat")

# Example: return to non-combat after all enemies dead
func _on_all_enemies_dead() -> void:
	AudioManager.set_music_state.emit("non_combat")

# ────────────────────────────────────────────────────────────
# STOPPING AUDIO
# ────────────────────────────────────────────────────────────

AudioManager.stop_bus.emit("SFX")       # stop all SFX
AudioManager.stop_bus.emit("Dialogue")  # stop all dialogue
AudioManager.stop_bus.emit("Music")     # stop music
AudioManager.stop_all.emit()            # stop everything

# ────────────────────────────────────────────────────────────
# AUTOLOAD SETUP ORDER (Project Settings > Autoload)
# ────────────────────────────────────────────────────────────
# 1. AudioManager       (res://audio_system/AudioManager.gd)
# 2. MusicStateManager  (res://audio_system/MusicStateManager.gd)
# 3. AudioSettings      (res://audio_system/AudioSettings.gd)

# ────────────────────────────────────────────────────────────
# AUDIO BUS LAYOUT (Project Settings > Audio > Buses)
# ────────────────────────────────────────────────────────────
# Bus 0: Master
# Bus 1: SFX      → parent: Master
# Bus 2: Dialogue → parent: Master
# Bus 3: Music    → parent: Master

# ────────────────────────────────────────────────────────────
# AUDIOSTREAMERACTIVE SETUP (in Godot editor)
# ────────────────────────────────────────────────────────────
# 1. Create resource: AudioStreamInteractive
# 2. Add 5 clips in this order:
#    [0] main_menu  — your menu music loop
#    [1] non_combat — exploration music loop
#    [2] combat     — action music loop
#    [3] shopping   — shop music loop
#    [4] dying      — tension/low-hp music loop
# 3. In Transitions tab: set each transition pair to
#    "Fade" with fade time 1.5s (or your preference)
# 4. Assign the resource to MusicStateManager.music_stream in Inspector
