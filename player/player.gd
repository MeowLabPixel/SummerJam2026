class_name Player extends CharacterBody3D

@export_group("movement setting")
@export var walk_speed = 280.0
@export var walk_Back_speed = 80.0
@export var trun_speed:= 180.0
@export var quick_trun_speed:= 0.3 #in second
@export var run_speed:=380.0
@export var aim_bone: SkeletonIK3D

@export_group("animation setting")
#@export var anim_player:AnimationPlayer
@export var default_blend_time:= 0.5
@export var anim: AnimationTree

@export_group("Data setting")
@export var MaxHP = 100
@export var hitboxF: Area3D
@export var hitboxB: Area3D
@export var stun_detect: Area3D
@export var pickup_detect: Area3D
var HP = MaxHP
var Hit_info = {
	"bullet": null,
	"location": null
}

#timer
@onready var knockdown_timer: Timer = $Knockdown_timer


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
var GunA = {
	"name": "Gun A",
	"Max_ammo": 10,
	"ammo": 10,
	"Super": false
}
var GunB = {
	"name": "Gun B",
	"Max_ammo": 3,
	"ammo": 3,
	"Super": false
}
var GunC = {
	"name": "Gun C",
	"Max_ammo": 5,
	"ammo": 5,
	"Super": false
}
var Gun = [GunA,GunB,GunC]
var curr_gun = Gun[0]
var curr_gun_index = 0
var near_enemy_list = []

@onready var camera: Node3D = $Camera
@onready var cross_hair: TextureRect = $Camera/edgeSpringArm3D/rearSpringArm3D/Camera3D/TextureRect
@onready var reload_timer: Timer = $Reload_timer

const BULLET = preload("uid://csdtdj7sci5vk")
@onready var bullet_lo: Node3D = $MeshInstance3D2/Node3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	stun_detect.body_entered.connect(stun_detect_in)
	stun_detect.body_exited.connect(stun_detect_out)
	pickup_detect.body_entered.connect(pickup_detect_area)

func set_velocity_from_motion(vel: Vector3)-> void:
	velocity = vel

func _physics_process(delta: float) -> void:
	move_and_slide()

func change_gun():
	#animation
	if curr_gun_index == Gun.size()-1:
		curr_gun_index = 0
	else:
		curr_gun_index +=1
	curr_gun = Gun[curr_gun_index]
	#spawan new gun

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
	if body.is_in_group("enemy"):
		near_enemy_list.append(body)
	check_if_near_stun()

func stun_detect_out (body: Node3D):
	if body.is_in_group("enemy"):
		var index = near_enemy_list.find(body,0)
		near_enemy_list.remove_at(index)
	check_if_near_stun()
		
func check_if_near_stun():
	is_near_stunt = false
	for i in near_enemy_list:
		if i.stun:
			is_near_stunt = true
			
func pickup_detect_area(body: Node3D):
	if body.is_in_group("object"):
		pass
