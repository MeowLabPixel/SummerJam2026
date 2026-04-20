extends State

var exit_anim_name = "HIT Left arm"
var start_anim_name = "HIT head act 3-take down"

func _enter() -> void:
	print(name)
	owner.aim_bone.stop()
	owner.anim.get("parameters/playback").travel("Knockdown")
	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)
	owner.hitboxF.monitoring = false
	owner.hitboxB.monitoring = false
	
func anim_done(namee: String):
	print(namee)
	if namee == exit_anim_name:
		finished.emit("Idle")
		owner.hitboxF.monitoring = true
		owner.hitboxB.monitoring = true
	if namee == start_anim_name:
		owner.knockdown_timer.timeout.connect(knock_timeout)
		owner.knockdown_timer.start()


		
func knock_timeout():
	owner.anim.get("parameters/Knockdown/playback").travel("out")
