extends State

var half = false
var fail_anim = "LEON GRAB Fail"
var win_anim ="HIT  Right Arm"
var mini_done = false
var is_exiting = false

func _enter() -> void:
	print(name)
	stop_moving()
	owner.aim_bone_on(false)
	owner.qte.visible = true
	half = false
	owner.anim.get("parameters/playback").travel("Grab")
	owner.hitboxF.monitoring = false
	owner.hitboxB.monitoring = false
	is_exiting = false
	
func _update(_delta:float) -> void:
	if owner.HP <= 0:
		finished.emit("Die")
	if not is_exiting:
		if owner.qte_bar.value == 100:
			owner.anim.get("parameters/Grab/playback").travel("Win")
			if not owner.anim.animation_finished.is_connected(anim_done):
				owner.anim.animation_finished.connect(anim_done)
			owner.qte.visible = false
			is_exiting = true
		if owner.start_qte:
			owner.qte_bar.value -= 1
		if owner.qte_bar.value <= 0 and owner.start_qte and not mini_done:
			owner.lost_HP(5)
			mini_done = true
			#some attac anim with zombie
			owner.qte.visible = false
			owner.anim.get("parameters/Grab/playback").travel("Fail")
			if not owner.anim.animation_finished.is_connected(anim_done):
				owner.anim.animation_finished.connect(anim_done)
			is_exiting = true
			#finished.emit("Idle")

func _exit() -> void:

	owner.start_qte = false
	owner.qte_bar.value = 0
	mini_done = false
	owner.hitboxF.monitoring = true
	owner.hitboxB.monitoring = true
	
		
func _state_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("ui_left") :
		half = true
	if Input.is_action_just_released("ui_right") and half:
		if not owner.start_qte:
			owner.start_qte = true
		half = false
		owner.qte_bar.value+=20
		
func anim_done(_namee: String):
	if _namee == fail_anim:
		finished.emit("Idle")
	if _namee == win_anim:
		finished.emit("Idle")
func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)
