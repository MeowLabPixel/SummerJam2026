extends State

var anim_node = "parameters/Main/QT/"
var QT_anim = "QT/Base"

func _enter() -> void:
	print(name)
	stop_moving()
	set_gun_anim()
	if owner.anim.get(owner.anim_playback).get_current_node() != "QT":
		owner.anim.get(owner.anim_playback).travel("QT")
	quick_turn()
	owner.aim_bone_on(false)
	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)
	if not owner.hitboxF.body_entered.is_connected(hitfront):
		owner.hitboxF.body_entered.connect(hitfront)
	if not owner.hitboxB.body_entered.is_connected(hitback):
		owner.hitboxB.body_entered.connect(hitback)

	
func quick_turn():
	owner.is_quick_turn =true
	var traget_y_rotation = owner.rotation.y + -PI
	
	var tween:= create_tween() as Tween
	tween.tween_property(owner,"rotation:y",traget_y_rotation,owner.quick_trun_speed)
	tween.finished.connect(func(): owner.camera.camera_rotation.x += PI; owner.is_quick_turn = false)
	
func _state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("Gun1"):
		switch_gun(0)
	if Input.is_action_pressed("Gun2"):
		switch_gun(1)
	if Input.is_action_pressed("Gun3"):
		switch_gun(2)

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
	set_gun_anim()
	#one shot anim

func set_gun_anim():
	if owner.Gun[owner.curr_gun_index].name == "pistol":
		owner.anim.set(anim_node + "conditions/pis",true)
		owner.anim.set(anim_node + "conditions/shot",false)
		if owner.anim.get(anim_node + "playback").get_current_node() != "Pis":
			owner.anim.get(anim_node + "playback").travel("Pis")
	elif owner.Gun[owner.curr_gun_index].name == "shotgun":
		owner.anim.set(anim_node + "conditions/pis",false)
		owner.anim.set(anim_node + "conditions/shot",true)
		if owner.anim.get(anim_node + "playback").get_current_node() != "Shot":
			owner.anim.get(anim_node + "playback").travel("Shot")

func anim_done(namee: String):
	if namee == QT_anim:
		finished.emit("Idle")

func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)
