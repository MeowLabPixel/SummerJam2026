extends Node3D

## Cutscene1Director.gd
## Plays cutscene animation + shows fullscreen video at a specific timestamp

signal cutscene_finished

@onready var anim         := $"Cutscene1/AnimationPlayer"
@onready var cutscene_cam := $"Cutscene1/Camera"
@onready var video_player := $CanvasLayer/VideoPlayerFullscreen

## Set this to the video file you want to play
@export_file("*.ogv") var video_path: String = "res://Audio System and SFX/Cutscene/MarwinCall.ogv"

## At what second in the cutscene should the video start? (e.g. 5.0 = 5 seconds in)
@export var video_start_time: float = 22.8

func _ready() -> void:
	if anim == null:
		push_error("[Cutscene1] AnimationPlayer not found!")
		return
	if cutscene_cam == null:
		push_error("[Cutscene1] Camera not found!")
		return
	
	# Load video
	if video_path != "" and ResourceLoader.exists(video_path):
		video_player.stream = load(video_path)
		print("[Cutscene1] Video loaded: ", video_path)
	else:
		print("[Cutscene1] No video file set or file not found")
	
	print("[Cutscene1] Starting cutscene...")
	play_cutscene()

func play_cutscene() -> void:
	await get_tree().process_frame
	
	# Activate cutscene camera
	cutscene_cam.make_current()
	
	# Play the merged animation
	anim.play("FullCutscene")
	print("[Cutscene1] Playing FullCutscene animation")
	
	# Wait for video trigger time
	if video_start_time > 0 and video_player.stream != null:
		await get_tree().create_timer(video_start_time).timeout
		play_video()
	
	# Wait for cutscene animation to finish
	await anim.animation_finished
	
	emit_signal("cutscene_finished")
	print("[Cutscene1] Cutscene finished!")

func play_video() -> void:
	if video_player.stream == null:
		push_warning("[Cutscene1] No video loaded!")
		return
	
	print("[Cutscene1] Showing fullscreen video...")
	video_player.visible = true
	video_player.play()
	
	# Wait for video to finish
	await video_player.finished
	
	# Hide video
	video_player.visible = false
	print("[Cutscene1] Video finished")
