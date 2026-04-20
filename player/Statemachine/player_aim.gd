extends State

func _enter() -> void:
	print(name)
	owner.is_aimming = true
	if owner.anim.get("parameters/playback").get_current_node() != "Idle":
		owner.anim.get("parameters/playback").travel("Idle")
	owner.cross_hair.visible = true

	
func _exit() -> void:
	owner.is_aimming = false
	owner.cross_hair.visible = false

func _state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("quick_turn") and not owner.is_quick_turn:
		finished.emit("Quick_turn")
	if Input.is_action_just_released("aim") :
		finished.emit("Idle")
	if Input.is_action_pressed("Reload") :
		finished.emit("Reload")
	if Input.is_action_pressed("gun swap") :
		owner.change_gun()
	if Input.is_action_pressed("click")and owner.curr_gun.ammo!=0:
		print("pew")
		var instance = owner.BULLET.instantiate()
		var lo = owner.bullet_lo.global_position
		instance.position = lo
		instance.transform.basis = owner.bullet_lo.transform.basis
		instance.add_to_group("bullet")
		get_parent().add_child(instance)
		owner.curr_gun.ammo-=1
