extends Motion

func _enter() -> void:
	if owner.is_aimming:
		finished.emit("Aim")
	print(name)
	if owner.HP <= owner.MaxHP/2 :
			owner.anim.get("parameters/playback").travel("Idle") #HUrt anim
	else:	
			owner.anim.get("parameters/playback").travel("Idle")

func _update(_delta:float) -> void:
	set_direction()
	calculate_velocity(SPEED,direction,_delta)
	if owner.HP <= 0:
		finished.emit("Die")
	if direction != Vector3.ZERO:
		finished.emit("Run")

func _state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("quick_turn") and not owner.is_quick_turn:
		finished.emit("Quick_turn")
	if Input.is_action_pressed("aim") :
		finished.emit("Aim")
	if Input.is_action_pressed("Reload") :
		finished.emit("Reload")
	if Input.is_action_pressed("grab_butt") :
		finished.emit("Grab")
	if Input.is_action_pressed("die_butt") :
		owner.HP =0
	if Input.is_action_pressed("gun swap") :
		owner.change_gun()
	if Input.is_action_pressed("hit") :
		finished.emit("Get_hit")
	if Input.is_action_pressed("knock_down") :
		finished.emit("Knockdown")
