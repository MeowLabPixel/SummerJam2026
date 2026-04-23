extends State

var hit_anim = "Hit/Leon hit"
static var direction: Vector3 = Vector3.ZERO
static var velocity: Vector3 = Vector3.ZERO
const acceleration:float = 1000
func _enter() -> void:
	print(name)
	owner.aim_bone_on(false)
	stop_moving()
	owner.lost_HP(1)
	owner.anim.get("parameters/playback").travel("Hit")
	knock_back()
	if not owner.anim.animation_finished.is_connected(anim_done):
		owner.anim.animation_finished.connect(anim_done)
		
func _exit() -> void:
		owner.Hit_info.location = null
		owner.Hit_info.bullet = null

func _update(_delta:float) -> void:
	velocity.x = move_toward(velocity.x,direction.x*5.0,acceleration*_delta)
	velocity.z = move_toward(velocity.z,direction.z*5.0,acceleration*_delta)
	owner.velocity= velocity
	
func anim_done(_namee: String):
	if _namee == hit_anim:
		finished.emit("Idle")
	elif _namee == hit_animF and owner.Hit_info.location == "front":
		finished.emit("Idle")
	elif _namee == hit_animB and owner.Hit_info.location == "back":
		finished.emit("Idle")

func stop_moving():
	var dire = Vector3.ZERO
	owner.set_velocity_from_motion(dire)
	
func knock_back():
	var input_dir = Vector2(0,0)
	if owner.Hit_info == "front":
		input_dir = Vector2(0,1)
	elif owner.Hit_info == "back":
		input_dir = Vector2(0,-1)
	direction = owner.global_transform.basis * Vector3(input_dir.x,0,input_dir.y)
