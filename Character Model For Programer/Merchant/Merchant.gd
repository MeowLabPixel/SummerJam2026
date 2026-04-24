extends Node3D

@export var anim_player: AnimationPlayer

func _ready():
	var idle: Animation = load("res://AnimationsExport/Merchant/IDLE.res")
	var open: Animation = load("res://AnimationsExport/Merchant/OPEN.res")

	var lib := AnimationLibrary.new()
	lib.add_animation("IDLE", idle)
	lib.add_animation("OPEN", open)

	anim_player.add_animation_library("", lib)

	anim_player.play("IDLE")
	