extends State

var half = false
var fail_anim = "Grab/Fail"
var win_anim ="Grab/Win"
var mini_done = false
var is_exiting = false
var is_grab: bool = false

func _enter() -> void:
	print(name)
	stop_moving()
	owner.aim_bone_on(false)

	owner.anim.get("parameters/playback").travel("Grab")
	owner.hitboxF.monitoring = false
	owner.hitboxB.monitoring = false
	is_exiting = false
	var timer := get_tree().create_timer(5.0)
	timer.timeout.connect(_grab_fallback)

func _grab_fallback() -> void:
	if not is_exiting:
		is_exiting = true
		owner.is_grab = false
		finished.emit("Idle")

func _exit() -> void:

	owner.start_qte = false
	owner.qte_bar.value = 0
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
	else:
		# Player ESCAPED
		owner.anim.get("parameters/Grab/playback").travel("Win")

	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)

func anim_done(_namee: String):
	owner.is_grab = false
	print("[Grab] anim_done received: ", _namee)
	if _namee == fail_anim:
		finished.emit("Idle")
	if _namee == win_anim:
		finished.emit("Knockdown")

func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)


func on_grabbed(success: bool) -> void:
	is_grab = success
