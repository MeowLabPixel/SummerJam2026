extends State

var hit_animF = "HIT Body"
var hit_animB = "HIT Body"
var hit_anim = "HIT Body"
#เติมกระเด็นไปข้างหน้า/หลัง
func _enter() -> void:
	print(name)
	owner.aim_bone_on(false)
	stop_moving()
	owner.lost_HP(1)
	if owner.Hit_info.location == "front":
		owner.anim.get(owner.anim_playback).travel("Hit")
	elif owner.Hit_info.location == "back":
		owner.anim.get(owner.anim_playback).travel("Hit")
	else:
		owner.anim.get(owner.anim_playback).travel("Hit")
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

func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)
