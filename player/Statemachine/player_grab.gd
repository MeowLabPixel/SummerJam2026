extends State

var half = false
var fail_anim = "Grab/Fail"
var win_anim ="Grab/Win"
var mini_done = false
var is_exiting = false
var is_grab: bool = false
var last_anim: String


func _enter() -> void:
	print(name)
	stop_moving()
	owner.aim_bone_on(false)

	owner.anim.get("parameters/playback").travel("Grab")
	owner.hitboxF.monitoring = false
	owner.hitboxB.monitoring = false
	is_exiting = false
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(_grab_fallback)

func _grab_fallback() -> void:
	print("Idle from Fallback.")
	if last_anim == win_anim:
		finished.emit("Idle")

func _exit() -> void:

	owner.start_qte = false
	owner.qte_bar.value = 0
	is_exiting = false
	mini_done = false
	
	owner.hitboxF.monitoring = true
	owner.hitboxB.monitoring = true
	# Disconnect animation callback to avoid duplicate connections
	if owner.anim and owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.disconnect(anim_done)

func resolve_grab(success: bool) -> void:

	owner.is_grab = true
	is_exiting = true
	

	if success:
		# Player LOST QTE (grab success)
		owner.anim.get("parameters/Grab/playback").travel("Fail")
		last_anim = fail_anim
	else:
		# Player ESCAPED
		owner.anim.get("parameters/Grab/playback").travel("Win")
		last_anim = win_anim

	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)

func anim_done(_namee: String):
	owner.is_grab = false
	print("[Grab] anim_done received: ", _namee)
	await get_tree().create_timer(1.35).timeout
	finished.emit("Idle")

func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)


func on_grabbed(success: bool) -> void:
	is_grab = success
