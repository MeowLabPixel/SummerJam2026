extends Motion

func _enter() -> void:
	print(name)
	owner.aim_bone.start()
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
	calculate_velocity(SPEED,direction,_delta)
	
	if direction == Vector3.ZERO:
		finished.emit("Idle")
		
func _state_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("quick_turn") and not owner.is_quick_turn:
		finished.emit("Quick_turn")
	if Input.is_action_pressed("sprint"):
		finished.emit("Sprint")
	if Input.is_action_pressed("Reload") :
		finished.emit("Reload")
	if Input.is_action_pressed("gun swap") :
		owner.change_gun()

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
