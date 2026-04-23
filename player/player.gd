class_name Player extends CharacterBody3D

@export_group("movement setting")
@export var walk_speed = 280.0
@export var walk_Back_speed = 80.0
@export var trun_speed:= 180.0
@export var quick_trun_speed:= 0.3 #in second
@export var run_speed:=380.0
@export var aim_bone: LookAtModifier3D
@export var aim_bone2: LookAtModifier3D

@export_group("animation setting")
#@export var anim_player:AnimationPlayer
@export var default_blend_time:= 0.5
@export var anim: AnimationTree
var anim_playback = "parameters/Main/playback"

@export_group("Data setting")
@export var MaxHP = 100
@export var hitboxF: Area3D
@export var hitboxB: Area3D
@export var stun_detect: Area3D
@export var pickup_detect: Area3D
@export var TD_hand: Area3D
var HP = MaxHP
var Hit_info = {
	"bullet": null,
	"location": null
}

#timer
@onready var knockdown_timer: Timer = $Knockdown_timer
#
#@export_group("GUN setting")
#@export var Pistol: Gun
#@export var Shotgun: Gun
#@export var Rifle: Gun




#QTE
@onready var qte: CanvasLayer = $Camera/edgeSpringArm3D/rearSpringArm3D/Camera3D/QTE
@onready var qte_bar: ProgressBar = $Camera/edgeSpringArm3D/rearSpringArm3D/Camera3D/QTE/ProgressBar
var start_qte = false

#Die
@onready var die: CanvasLayer = $Camera/edgeSpringArm3D/rearSpringArm3D/Camera3D/Die
@onready var die_anim: AnimationPlayer = $Camera/edgeSpringArm3D/rearSpringArm3D/Camera3D/Die/AnimationPlayer

const GRAVITY = -9.81
var is_quick_turn: bool = false
var is_aimming:bool = false
var is_reload:bool = false
var is_grab:bool = false
var is_knockdown:bool = false
var is_near_stunt:bool = false

#gun
@export var gun_controller: GunController

#var GunA = {
	#"name": "pistol",
	#"Gun" : Pistol
#}
#var GunB = {
	#"name": "shotgun",
	#"Gun" : Shotgun
#}
#var GunC = {
	#"name": "rifle",
	#"Gun" : Rifle
#}
#var Gun = [GunA,GunB,GunC]
#var curr_gun = Gun[0]
#var curr_gun_index = 0
var near_enemy_list = []

@export_group("Crosshair")
@export var crosshair_texture: Texture2D
@export var min_scale: float = 0.5
@export var max_scale: float = 2.0
@export var crosshair_color: Color = Color.WHITE

@onready var camera: Node3D = $Camera
@onready var cross_hair: TextureRect = $Camera/edgeSpringArm3D/rearSpringArm3D/Camera3D/TextureRect
@onready var reload_timer: Timer = $Reload_timer

#const BULLET = preload("uid://csdtdj7sci5vk")
#@@onready var bullet_lo: Node3D = $"Re4Lom Base Rig/rig/Skeleton3D/Gun/MeshInstance3D/Node3D"

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	add_to_group("player")
	stun_detect.body_entered.connect(stun_detect_in)
	stun_detect.body_exited.connect(stun_detect_out)
	pickup_detect.area_entered.connect(pickup_detect_area)

	if cross_hair:
		cross_hair.visible = false
		cross_hair.texture = crosshair_texture
		cross_hair.modulate = crosshair_color
		# Ensure size matches the image to maintain quality
		cross_hair.size = Vector2(512, 512)
		cross_hair.pivot_offset = Vector2(256, 256)
		cross_hair.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
		
func _process(delta: float) -> void:
	update_crosshair_accuracy(delta)

func update_crosshair_accuracy(delta: float) -> void:
	if not cross_hair:
		return

	cross_hair.visible = is_aimming
	if not cross_hair.visible:
		return

	if gun_controller and gun_controller.current_gun:
		var gun: Gun = gun_controller.current_gun
		# Normalize spread based on the gun's min/max spread
		var spread_factor = clamp((gun.current_spread - gun.min_spread) / (gun.max_spread - gun.min_spread), 0.0, 1.0)
		var target_scale_val = lerp(min_scale, max_scale, spread_factor)

		cross_hair.scale = cross_hair.scale.lerp(Vector2(target_scale_val, target_scale_val), delta * 20.0)
		
func set_velocity_from_motion(vel: Vector3)-> void:
	velocity = vel

func _physics_process(_delta: float) -> void:
	move_and_slide()

#func change_gun():
#	if gun_controller:
#		gun_controller.next_gun()
#		curr_gun_index = gun_controller.current_gun_index
#	else:
#		if curr_gun_index == gun_list.size()-1:
#			curr_gun_index = 0
#		else:
#			curr_gun_index +=1
#		curr_gun = gun_list[curr_gun_index]

func take_damage(amount: int) -> void:
	lost_HP(amount)
	print("[Player] Took %d damage — HP: %d/%d" % [amount, HP, MaxHP])

	if HP <= 0:
		print("[Player] Dead")

func lost_HP(amount):
	if HP -amount <= 0:
		HP = 0
	else:
		HP -=amount
		
func Heal(amount):
	if HP +amount >= MaxHP:
		HP = MaxHP
	else:
		HP +=amount
		
func stun_detect_in (body: Node3D):
	if body is EnemyBase :
		near_enemy_list.append(body)
	check_if_near_stun()

func stun_detect_out (body: Node3D):
	if body is EnemyBase and  near_enemy_list.has(body):
		var index = near_enemy_list.find(body,0)
		near_enemy_list.remove_at(index)
	check_if_near_stun()
		
func check_if_near_stun():
	is_near_stunt = false
	for i in near_enemy_list:
		if i.get_node("EnemyStateMachine").current_state == i.get_node("EnemyStateMachine").state_map["StateStun"]:
			is_near_stunt = true
			
		
func aim_bone_on(value):
	aim_bone.active = value
	aim_bone2.active = value

func pickup_detect_area(area: Area3D):
	if area.is_in_group("object"):
		area._collect()
