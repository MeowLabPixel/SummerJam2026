extends State

var hit_anim = "HIT Body"

func _enter() -> void:
	print(name)
	owner.HP -=1
	owner.anim.get("parameters/playback").travel("Hit")
	owner.anim.animation_finished.connect(anim_done)
	
func anim_done(name: String):
	if name == hit_anim:
		finished.emit("Idle")
