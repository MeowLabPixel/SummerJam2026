extends State

func _enter() -> void:
	print(name)
	if owner.anim.get("parameters/playback").get_current_node() != "Idle":
		owner.anim.get("parameters/playback").travel("Idle")
	quick_turn()
	owner.aim_bone.stop()
	if not owner.hitboxF.body_entered.is_connected(hitfront):
		owner.hitboxF.body_entered.connect(hitfront)
	if not owner.hitboxB.body_entered.is_connected(hitback):
		owner.hitboxB.body_entered.connect(hitback)
	
func quick_turn():
	owner.is_quick_turn =true
	var traget_y_rotation = owner.rotation.y + PI
	
	var tween:= create_tween() as Tween
	tween.tween_property(owner,"rotation:y",traget_y_rotation,owner.quick_trun_speed)
	tween.finished.connect(func(): owner.camera.camera_rotation.x += PI; owner.is_quick_turn = false; finished.emit("Idle"))
	
func _state_input(_event: InputEvent) -> void:
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
