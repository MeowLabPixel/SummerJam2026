## ZombieAnimSet: assign one of these per enemy scene to define its animation names.
class_name ZombieAnimSet
extends Resource

@export var idle        := "Zombie Idle"
@export var walk_1      := "Walk zom va1"
@export var walk_2      := "Walk zombie va2"
@export var attack_1    := "Zombie Attack 1"
@export var attack_2    := "Zombie Attack 2"
@export var grab_reach  := "Zombie Attempt Grab"
@export var grab_hold   := "Zombie Grab success_"
@export var grab_success := "Zombie Grab success"
@export var grab_fail   := "Zombie Grab fail"
@export var range_idle  := "Zombie Idle"
@export var range_shoot := "Zombie Idle"
@export var balloon_idle  := "Balloone Zombie Idle"
@export var balloon_throw := "Balloone Zombie Idle"
@export var dead        := "dEAD ZOMBIE Start up"
@export var dead_walk   := "dEAD ZOMBIE walk"
@export var hit_body    := "HIT Body"
@export var hit_left_arm  := "HIT Left arm"
@export var hit_right_arm := "HIT  Right Arm"
@export var hit_head_act1 := "HIT head act 1 - when get hit"
@export var hit_head_act2 := "HIT head act 2(Stun_idle)"
@export var hit_head_act3 := "HIT head act 3-take down"
@export var hit_head_act4 := "HIT head act 4 (Take_down_idle)"
@export var hit_head_act5 := "HIT head act 5 (get_up )"
@export var hit_lleg_act1 := "Hit Leg act 1 Slipping"
@export var hit_lleg_act2 := "Hit Leg act 2 (Slipping_Ilde)"
@export var hit_lleg_act3 := "Hit Leg act 3 (Take_down)"
@export var hit_lleg_act4 := "Hit Leg act 4 (Take_down_idle)"
@export var hit_lleg_act5 := "HIT Leg act 5 (get_up )"
@export var hit_rleg_act1 := "Hit Leg act 1 Slipping"
@export var hit_rleg_act2 := "Hit Leg act 2 (Slipping_Ilde)"
@export var hit_rleg_act3 := "Hit Leg act 3 (Take_down)"
@export var hit_rleg_act4 := "Hit Leg act 4 (Take_down_idle)"
@export var hit_rleg_act5 := "HIT Leg act 5 (get_up )"

func random_walk() -> String:
	return walk_1 if randf() < 0.5 else walk_2

func random_attack() -> String:
	return attack_1 if randf() < 0.5 else attack_2

func hit_reaction(hit_zone: String) -> String:
	match hit_zone:
		"head":      return hit_head_act1
		"left_leg":  return hit_lleg_act1
		"right_leg": return hit_rleg_act1
		"foot":      return hit_lleg_act1
		"right_arm": return hit_right_arm
		"left_arm":  return hit_left_arm
		_:           return hit_body

func stun_idle(hit_zone: String) -> String:
	match hit_zone:
		"head":             return hit_head_act2
		"left_leg", "foot": return hit_lleg_act2
		"right_leg":        return hit_rleg_act2
		_:                  return hit_head_act2

func takedown_anim(hit_zone: String) -> String:
	match hit_zone:
		"left_leg", "foot": return hit_lleg_act3
		"right_leg":        return hit_rleg_act3
		_:                  return hit_head_act3

func takedown_idle(hit_zone: String) -> String:
	match hit_zone:
		"right_leg":        return hit_rleg_act4
		"left_leg", "foot": return hit_lleg_act4
		_:                  return hit_head_act4

func get_up_anim(hit_zone: String) -> String:
	return hit_rleg_act5 if hit_zone == "right_leg" else hit_lleg_act5
