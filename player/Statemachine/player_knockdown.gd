extends State

var exit_anim_name = "Knockdown/out"
var start_anim_name = "Knockdown/down"

func _enter() -> void:
	print(name)
	stop_moving()
	owner.aim_bone_on(false)
	owner.anim.get(owner.anim_playback).travel("Knockdown")
	owner.hitboxF.monitoring = false
	owner.hitboxB.monitoring = false
	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)

func _exit() -> void:
	owner.hitboxF.monitoring = true
	owner.hitboxB.monitoring = true
	if owner.anim and owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.disconnect(anim_done)

func anim_done(_namee: String):
	if _namee == exit_anim_name:
		finished.emit("Idle")

func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)
