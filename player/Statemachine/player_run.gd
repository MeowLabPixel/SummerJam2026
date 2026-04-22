extends Motion

func _enter() -> void:
	print(name)
	owner.aim_bone.start()
	if owner.HP <= owner.MaxHP/2 :
		owner.anim.get(owner.anim_playback).travel("Run")
	else:
		if owner.anim.get(owner.anim_playback).get_current_node() != "Run":
			owner.anim.get(owner.anim_playback).travel("Run")	
	gun_anim()
	if not owner.hitboxF.body_entered.is_connected(hitfront):
		owner.hitboxF.body_entered.connect(hitfront)
	if not owner.hitboxB.body_entered.is_connected(hitback):
		owner.hitboxB.body_entered.connect(hitback)

func _update(_delta:float) -> void:
	set_direction()
	calculate_velocity(SPEED,direction,_delta)
	#print(owner.anim.get("parameters/Main/Run/playback").get_current_node())
	owner.anim.set("parameters/Main/Run/Pis/BlendSpace2D/blend_position",input_dir)
	owner.anim.set("parameters/Main/Run/Shot/BlendSpace2D/blend_position",input_dir)
	#owner.anim.get("parameters/Main/Run/Pis/BlendSpace2D/blend_position").set(direction)
	if owner.anim.get("parameters/Main/Run/playback").get_current_node() == "Start":
		gun_anim()
	if direction == Vector3.ZERO:
		finished.emit("Idle")
		
func _state_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("quick_turn") and not owner.is_quick_turn:
		finished.emit("Quick_turn")
	if Input.is_action_pressed("sprint"):
		finished.emit("Sprint")
	if Input.is_action_pressed("Reload") :
		finished.emit("Reload")
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

func switch_gun(num:float):
	owner.curr_gun_index = num
	owner.curr_gun = owner.Gun[owner.curr_gun_index]
	#one shot anim

func gun_anim():
	if owner.curr_gun.name == "pistol":
		print("A")
		if owner.anim.get("parameters/Main/Run/playback").get_current_node() != "Pis":
			owner.anim.get("parameters/Main/Run/playback").travel("Pis")	
	elif owner.curr_gun.name == "shot":
		print("B")
		if owner.anim.get("parameters/Main/Run/playback").get_current_node() != "Shot":
			owner.anim.get("parameters/Main/Run/playback").travel("Shot")
