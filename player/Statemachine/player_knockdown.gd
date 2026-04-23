extends State

var exit_anim_name = "HIT Left arm"
var start_anim_name = "HIT head act 3-take down"

func _enter() -> void:
	print(name)
	stop_moving()
	owner.aim_bone_on(false)
	owner.anim.get(owner.anim_playback).travel("Knockdown")
	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)
	owner.hitboxF.monitoring = false
	owner.hitboxB.monitoring = false
	
func anim_done(_namee: String):
	print(_namee)
	if _namee == exit_anim_name:
		finished.emit("Idle")
		owner.hitboxF.monitoring = true
		owner.hitboxB.monitoring = true
	if _namee == start_anim_name:
		owner.knockdown_timer.timeout.connect(knock_timeout)
		owner.knockdown_timer.start()

func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)
		
func knock_timeout():
	owner.anim.get("parameters/Knockdown/playback").travel("out")
