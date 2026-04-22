extends State
#temp can do when idle,run,sprint
var anim_name = "HIT Left arm"

func _enter() -> void:
	print(name)
	owner.aim_bone_on(false)
	stop_moving()
	owner.anim.get(owner.anim_playback).travel("Takedown")
	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)
		
func anim_done(namee: String):
	if namee == anim_name:
		finished.emit("Idle")

func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)
