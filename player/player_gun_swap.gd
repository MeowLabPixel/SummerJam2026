extends Motion

func _enter() -> void:
	owner.curr_gun = owner.Gun[owner.curr_gun_index]
	#play gunswap anim

func anim_done(namee: String):
	pass

func _update(_delta:float) -> void:
	set_direction()
	calculate_velocity(SPEED,direction,_delta)


#switch to 1 shot in run/sprint/idle add func here too
