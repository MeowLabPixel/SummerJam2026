extends State

var hit_animF = "HIT Body"
var hit_animB = "HIT Body"
var hit_anim = "HIT Body"

func _enter() -> void:
	print(name)
	owner.aim_bone.stop()
	owner.HP -=1
	if owner.Hit_info.location == "front":
		owner.anim.get("parameters/playback").travel("Hit")
	elif owner.Hit_info.location == "back":
		owner.anim.get("parameters/playback").travel("Hit")
	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)
		
func _exit() -> void:
		owner.Hit_info.location = null
		owner.Hit_info.bullet = null
	
func anim_done(namee: String):
	if namee == hit_anim:
		finished.emit("Idle")
	elif namee == hit_animF and owner.Hit_info.location == "front":
		finished.emit("Idle")
	elif namee == hit_animB and owner.Hit_info.location == "back":
		finished.emit("Idle")
