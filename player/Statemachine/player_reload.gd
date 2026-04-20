extends State

var reload_anim = "HIT  Right Arm"

func _enter() -> void:
	print(name)
	reloading()
	owner.aim_bone.stop()
	if not owner.hitboxF.body_entered.is_connected(hitfront):
		owner.hitboxF.body_entered.connect(hitfront)
	if not owner.hitboxB.body_entered.is_connected(hitback):
		owner.hitboxB.body_entered.connect(hitback)
	
	
func _state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("Reload"):
		var next_ammo = owner.curr_gun.ammo +1
		if next_ammo < owner.curr_gun.Max_ammo:
			reloading()
		
func reloading():
	var next_ammo = owner.curr_gun.ammo +1
	if next_ammo > owner.curr_gun.Max_ammo:
		#play super pump
		#super shot here
		owner.anim.get("parameters/playback").travel("Reload")
		owner.anim.get("parameters/playback").start("Reload")
		if not owner.anim.animation_finished.is_connected(anim_done):
			owner.anim.animation_finished.connect(anim_done)
	else:
		owner.curr_gun.ammo +=1
		#reload anim
		owner.anim.get("parameters/playback").travel("Reload")
		owner.anim.get("parameters/playback").start("Reload")
		if not owner.anim.animation_finished.is_connected(anim_done):
			owner.anim.animation_finished.connect(anim_done)
		if not owner.reload_timer.timeout.is_connected(reload_timeout):
			owner.reload_timer.timeout.connect(reload_timeout)	

	
	
func anim_done(namee:String):
	print(namee)
	if namee == reload_anim:
		owner.anim.get("parameters/playback").travel("Idle")
		owner.reload_timer.start()
	
func reload_timeout():
	finished.emit("Idle")

func hitfront(body: Node3D):
	if body.is_in_group("attack"):
		owner.Hit_info.bullet = body
		owner.Hit_info.location = "front"
		finished.emit("Get_hit")
func hitback(body: Node3D):
	if body.is_in_group("attack"):
		owner.Hit_info.bullet = body
		owner.Hit_info.location = "back"
		finished.emit("Get_hit")
