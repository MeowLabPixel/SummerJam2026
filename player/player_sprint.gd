extends Motion

func _enter() -> void:
	print(name)
	if owner.HP <= owner.MaxHP/2 :
		owner.anim.get("parameters/playback").travel("Run")
	else:
		owner.anim.get("parameters/playback").travel("Run")
	if not owner.hitboxF.body_entered.is_connected(hitfront):
		owner.hitboxF.body_entered.connect(hitfront)
	if not owner.hitboxB.body_entered.is_connected(hitback):
		owner.hitboxB.body_entered.connect(hitback)


func _update(_delta:float) -> void:
	set_direction()
	calculate_velocity(SPEED_sprint,direction,_delta)
	
	if direction == Vector3.ZERO:
		finished.emit("Idle")
		
func _state_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("quick_turn") and not owner.is_quick_turn:
		finished.emit("Quick_turn")
	if Input.is_action_just_released("sprint"):
		finished.emit("Run")
	if Input.is_action_pressed("Reload") :
		finished.emit("Reload")
	if Input.is_action_pressed("gun swap") :
		finished.emit("Gun_swap")
	if Input.is_action_pressed("Gun1"):
		switch_gun(0)
	if Input.is_action_pressed("Gun2"):
		switch_gun(1)
	if Input.is_action_pressed("Gun3"):
		switch_gun(2)
	if Input.is_action_pressed("Takedown") and owner.is_near_stunt:
		finished.emit("Takedown")

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

func switch_gun(num:int):
	if owner.gun_controller:
		owner.gun_controller.switch_gun(num)
		owner.curr_gun_index = num
	else:
		owner.curr_gun_index = num
		owner.curr_gun = owner.Gun[owner.curr_gun_index]
	#one shot anim
