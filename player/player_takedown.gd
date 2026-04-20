extends State
#temp can do when idle,run,sprint
var anim_name = "HIT Left arm"

func _enter() -> void:
	print(name)
	owner.aim_bone.stop()
	owner.anim.get("parameters/playback").travel("Takedown")
	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)
		
func anim_done(namee: String):
	if namee == anim_name:
		finished.emit("Idle")
