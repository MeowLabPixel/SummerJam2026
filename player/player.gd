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

#gun
@export var gun_controller: GunController

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

@onready var camera: Node3D = $Camera
@onready var cross_hair: TextureRect = $Camera/edgeSpringArm3D/rearSpringArm3D/Camera3D/TextureRect
@onready var reload_timer: Timer = $Reload_timer

const BULLET = preload("uid://csdtdj7sci5vk")
@onready var bullet_lo: Node3D = $MeshInstance3D2/Node3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func set_velocity_from_motion(vel: Vector3)-> void:
	velocity = vel

func _physics_process(delta: float) -> void:
	move_and_slide()

func change_gun():
	if gun_controller:
		gun_controller.next_gun()
		curr_gun_index = gun_controller.current_gun_index
		# We can still keep curr_gun if other systems use it, 
		# but ideally we should transition to use gun_controller.current_gun
	else:
		# Fallback to old system if no gun_controller
		if curr_gun_index == Gun.size()-1:
			curr_gun_index = 0
		else:
			curr_gun_index +=1
		curr_gun = Gun[curr_gun_index]

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
