class_name Player extends CharacterBody3D

@export_group("movement setting")
@export var walk_speed = 280.0
@export var walk_Back_speed = 80.0
@export var trun_speed:= 180.0
@export var quick_trun_speed:= 0.3 #in second
@export var run_speed:=380.0

@export_group("animation setting")
@export var animationplayer:AnimationPlayer
@export var default_blend_time:= 0.5

@export_group("Data setting")
@export var HP = 100
@export var Ammo = 10

const GRAVITY = -9.81
var is_quick_turn: bool = false
var is_aimming:bool = false
var is_reload:bool = false
var is_grab:bool = false
var is_knockdown:bool = false

@onready var camera: Node3D = $Camera

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func set_velocity_from_motion(vel: Vector3)-> void:
	velocity = vel

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	move_and_slide()


#func handle_turn(delta):
	#var turn_dir = Input.get_axis("left","right")
	#rotation_degrees.y -= turn_dir* trun_speed*delta
	#camera.camera_turning_rotation.x += deg_to_rad(turn_dir* trun_speed*delta)
	#camera.camera_rotation.x += deg_to_rad(turn_dir* trun_speed*delta)
	##transform.basis = Basis()
	##
	##rotate_object_local(Vector3(0,1,0),-camera.camera_rotation.x)
#
#func handle_walk(delta):
	#var input_dir = Input.get_axis("down","up")
	#var SPD = walk_speed
	#if input_dir < 0:
		#SPD = walk_Back_speed
	#var walk_velocity = -basis.z * input_dir*SPD*delta
	#velocity.x = walk_velocity.x
	#velocity.z = walk_velocity.z
#
#func hadle_run(delta):
	#if Input.is_action_pressed("down"):
		#handle_walk(delta)
		#return
	#var input_dir = Input.get_action_strength("up")
	#var walk_velocity = -basis.z * input_dir* run_speed *delta
	#velocity.x = walk_velocity.x
	#velocity.z = walk_velocity.z
#
##func handle_gravity(delta):
	##if is_on_floor():
		##velocity.y = -2
	##else:
		##velocity.y += GRAVITY*delta
#
#func quick_turn():
	#is_quick_turn =true
	#var traget_y_rotation = rotation.y + PI
	#
	#var tween:= create_tween() as Tween
	#tween.tween_property(self,"rotation:y",traget_y_rotation,quick_trun_speed)
	#tween.finished.connect(func(): camera.camera_rotation.x += PI;is_quick_turn = false)
#
#func _physics_process(delta: float) -> void:
	#if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		#handle_turn(delta)
	#if not is_aimming:
		#if Input.is_action_pressed("sprint"):
			#hadle_run(delta)
		#else:
			#handle_walk(delta)
		#
	#if is_quick_turn or is_aimming:
		#velocity.x =0
		#velocity.z =0
	#move_and_slide()
	#
#func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_action_pressed("quick_turn") and not is_quick_turn:
		#quick_turn()
