extends Motion

func _enter() -> void:
	print(name)

func _update(_delta:float) -> void:
	set_direction()
	calculate_velocity(SPEED,direction,_delta)
	
	if direction == Vector3.ZERO:
		finished.emit("Idle")
		
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("quick_turn") and not owner.is_quick_turn:
		finished.emit("Quick_turn")
