extends State

func _enter() -> void:
	print(name)
	owner.is_aimming = true
	if owner.anim.get("parameters/playback").get_current_node() != "Idle":
		owner.anim.get("parameters/playback").travel("Idle")
	owner.cross_hair.visible = true
	owner.aim_bone.start()
	if not owner.hitboxF.body_entered.is_connected(hitfront):
		owner.hitboxF.body_entered.connect(hitfront)
	if not owner.hitboxB.body_entered.is_connected(hitback):
		owner.hitboxB.body_entered.connect(hitback)

	
func _exit() -> void:
	owner.is_aimming = false
	owner.cross_hair.visible = false
	
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

func _state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("quick_turn") and not owner.is_quick_turn:
		finished.emit("Quick_turn")
	if Input.is_action_just_released("aim") :
		finished.emit("Idle")
	if Input.is_action_pressed("Reload") :
		finished.emit("Reload")
	if Input.is_action_pressed("Gun1"):
		switch_gun(0)
	if Input.is_action_pressed("Gun2"):
		switch_gun(1)
	if Input.is_action_pressed("Gun3"):
		switch_gun(2)
	if Input.is_action_pressed("click")and owner.curr_gun.ammo!=0:
		print("pew")
		var instance = owner.BULLET.instantiate()
		var lo = owner.bullet_lo.global_position
		instance.position = lo
		instance.transform.basis = owner.bullet_lo.transform.basis
		instance.add_to_group("bullet")
		get_parent().add_child(instance)
		owner.curr_gun.ammo-=1

func switch_gun(num:float):
	owner.curr_gun_index = num
	owner.curr_gun = owner.Gun[owner.curr_gun_index]
	#one shot anim
