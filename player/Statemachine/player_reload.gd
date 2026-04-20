extends State

var reload_anim = "HIT Body"

func _enter() -> void:
	print(name)
	reloading()
	
	
func _state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("Reload"):
		#reloading()
		finished.emit("Reload")
		
func reloading():
	var next_ammo = owner.curr_gun.ammo +1
	if next_ammo > owner.curr_gun.Max_ammo:
		#play super pump
		#super shot here
		owner.anim.get("parameters/playback").travel("Hit")
		if not owner.anim.animation_finished.is_connected(anim_done):
			owner.anim.animation_finished.connect(anim_done)
		
	else:
		owner.curr_gun.ammo +=1
		#reload anim
		owner.anim.get("parameters/playback").travel("Hit")
		if not owner.anim.animation_finished.is_connected(anim_done):
			owner.anim.animation_finished.connect(anim_done)
		if not owner.reload_timer.timeout.is_connected(reload_timeout):
			owner.reload_timer.timeout.connect(reload_timeout)	

	
	
func anim_done(namee:String):
	if namee == reload_anim:
		owner.anim.get("parameters/playback").travel("Idle")
		owner.reload_timer.start()
	
func reload_timeout():
	finished.emit("Idle")
