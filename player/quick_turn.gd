extends State

func _enter() -> void:
	print(name)
	if owner.anim.get("parameters/playback").get_current_node() != "Idle":
		owner.anim.get("parameters/playback").travel("Idle")
	quick_turn()
	
func quick_turn():
	owner.is_quick_turn =true
	var traget_y_rotation = owner.rotation.y + PI
	
	var tween:= create_tween() as Tween
	tween.tween_property(owner,"rotation:y",traget_y_rotation,owner.quick_trun_speed)
	tween.finished.connect(func(): owner.camera.camera_rotation.x += PI; owner.is_quick_turn = false; finished.emit("Idle"))
	
func _state_input(event: InputEvent) -> void:
	if Input.is_action_pressed("gun swap") :
		owner.change_gun()
