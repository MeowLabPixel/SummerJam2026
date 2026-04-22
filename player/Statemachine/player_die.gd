extends State

func _enter() -> void:
	print(name)
	owner.aim_bone.stop()
	owner.anim.get(owner.anim_playback).travel("Die")
	owner.die.visible = true
	owner.die_anim.play("in")
