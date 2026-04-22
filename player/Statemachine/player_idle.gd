extends Motion

func _enter() -> void:
	owner.aim_bone_on(true)
	if owner.is_aimming:
		finished.emit("Aim")
	print(name)
	set_gun_anim()
	if owner.HP <= owner.MaxHP/2 :
			owner.anim.get(owner.anim_playback).travel("Idle") #HUrt anim
	else:	
			owner.anim.get(owner.anim_playback).travel("Idle")
			
	if not owner.hitboxF.body_entered.is_connected(hitfront):
		owner.hitboxF.body_entered.connect(hitfront)
	if not owner.hitboxB.body_entered.is_connected(hitback):
		owner.hitboxB.body_entered.connect(hitback)


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
	if Input.is_action_pressed("hit") :
		finished.emit("Get_hit")
	if Input.is_action_pressed("knock_down") :
		finished.emit("Knockdown")
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
		print("swap to Gun "+ str(num))
	if num!= owner.curr_gun_index:
		owner.curr_gun_index = num
			owner.curr_gun = owner.Gun[owner.curr_gun_index]
		set_gun_anim()
		#one shot anim
	
func set_gun_anim():
	if owner.Gun[owner.curr_gun_index].name == "pistol":
		owner.anim.set("parameters/Main/Idle/conditions/pis",true)
		owner.anim.set("parameters/Main/Idle/conditions/shot",false)
		if owner.anim.get("parameters/Main/Idle/playback").get_current_node() != "Pis":
			owner.anim.get("parameters/Main/Idle/playback").travel("Pis")
	elif owner.Gun[owner.curr_gun_index].name == "shotgun":
		owner.anim.set("parameters/Main/Idle/conditions/pis",false)
		owner.anim.set("parameters/Main/Idle/conditions/shot",true)
		if owner.anim.get("parameters/Main/Idle/playback").get_current_node() != "Shot":
			owner.anim.get("parameters/Main/Idle/playback").travel("Shot")
