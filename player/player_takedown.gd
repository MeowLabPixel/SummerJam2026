extends State
#temp can do when idle,run,sprint
var anim_name = "TD/Take down anim"

func _enter() -> void:
	print(name)
	owner.stun_detect.monitorable = true
	owner.aim_bone_on(false)
	stop_moving()
	owner.anim.get(owner.anim_playback).travel("Takedown")
	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)
	owner.hitboxF.monitoring = false
	owner.hitboxB.monitoring = false
		
func _exit() -> void:
	owner.stun_detect.monitorable =false
	if owner.anim and owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.disconnect(anim_done)

func anim_done(namee: String):
	if namee == anim_name:
		finished.emit("Idle")
		owner.hitboxF.monitoring = true
		owner.hitboxB.monitoring = true

func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)
