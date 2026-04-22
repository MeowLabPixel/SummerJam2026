extends Motion

var D

func _enter() -> void:
	print(name)
	owner.aim_bone_on(true)
	if owner.HP <= owner.MaxHP/2 :
		owner.anim.get(owner.anim_playback).travel("Run")
	else:
		owner.anim.get(owner.anim_playback).travel("Run")
	if not owner.hitboxF.body_entered.is_connected(hitfront):
		owner.hitboxF.body_entered.connect(hitfront)
	if not owner.hitboxB.body_entered.is_connected(hitback):
		owner.hitboxB.body_entered.connect(hitback)
	owner.anim.set("parameters/Main/Run/Pis/TimeScale/scale",2.0)
	owner.anim.set("parameters/Main/Run/Shot/TimeScale/scale",2.0)


func _update(_delta:float) -> void:
	set_direction()
	calculate_velocity(SPEED_sprint,direction,_delta)
	
	owner.anim.set("parameters/Main/Run/Pis/BlendSpace2D/blend_position",input_dir)
	owner.anim.set("parameters/Main/Run/Shot/BlendSpace2D/blend_position",input_dir)
	#owner.anim.get("parameters/Main/Run/Pis/BlendSpace2D/blend_position").set(direction)
	D=_delta
	if direction == Vector3.ZERO:
		finished.emit("Idle")
		
func _exit() -> void:
	owner.anim.set("parameters/Main/Run/Pis/TimeScale/scale",1.0)
	owner.anim.set("parameters/Main/Run/Shot/TimeScale/scale",1.0)
	
	
func _state_input(event: InputEvent) -> void:
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
	if Input.is_action_pressed("aim") :
		finished.emit("Aim")



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
	if owner.gun_controller:
		owner.gun_controller.switch_gun(num)
		owner.curr_gun_index = num
	else:
		owner.curr_gun_index = num
		owner.curr_gun = owner.Gun[owner.curr_gun_index]
			
	print("swap to Gun "+ str(num))
	if num!= owner.curr_gun_index:
		owner.curr_gun_index = num
		owner.curr_gun = owner.Gun[owner.curr_gun_index]
		set_gun_anim()

		#one shot anim
func set_gun_anim():
	var index = owner.Gun.find(owner.curr_gun,0)
	if owner.Gun[owner.curr_gun_index].name == "pistol":
		owner.anim.set("parameters/Main/Run/conditions/pis",true)
		owner.anim.set("parameters/Main/Run/conditions/shot",false)
		if owner.anim.get("parameters/Main/Run/playback").get_current_node() != "Pis":
			owner.anim.get("parameters/Main/Run/playback").travel("Pis")
	elif owner.Gun[owner.curr_gun_index].name == "shotgun":
		owner.anim.set("parameters/Main/Run/conditions/pis",false)
		owner.anim.set("parameters/Main/Run/conditions/shot",true)
		if owner.anim.get("parameters/Main/Run/playback").get_current_node() != "Shot":
			owner.anim.get("parameters/Main/Run/playback").travel("Shot")
