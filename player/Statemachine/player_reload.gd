extends State

var reload_anim = "RR/re"

func _enter() -> void:
	print(name)
	reloading()
	stop_moving()
	owner.aim_bone_on(false)
	if not owner.hitboxF.body_entered.is_connected(hitfront):
		owner.hitboxF.body_entered.connect(hitfront)
	if not owner.hitboxB.body_entered.is_connected(hitback):
		owner.hitboxB.body_entered.connect(hitback)
	
	
func _state_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Reload"):
		reloading()
		
func reloading():
	if owner.gun_controller:
		if not owner.gun_controller.current_gun.is_super_ready:
			owner.gun_controller.current_gun.pump_air()
			owner.anim.get(owner.anim_playback).travel("Reload")
			owner.anim.get(owner.anim_playback).start("Reload")
			if owner.gun_controller.current_gun.is_super_ready:
				owner.anim.set("parameters/Main/Reload/BlendTree/TimeScale/scale",0.5)

			if not owner.anim.animation_finished.is_connected(anim_done):
				owner.anim.animation_finished.connect(anim_done)
			
			# Restart timer if they pump again
			owner.reload_timer.start()
			if not owner.reload_timer.timeout.is_connected(reload_timeout):
				owner.reload_timer.timeout.connect(reload_timeout)	

	
	
func anim_done(namee:String):
	print(namee)
	if namee == reload_anim:
		owner.anim.get(owner.anim_playback).travel("Idle")
		owner.reload_timer.start()
		owner.anim.set("parameters/Main/Reload/BlendTree/TimeScale/scale",1)
	
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
func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)
