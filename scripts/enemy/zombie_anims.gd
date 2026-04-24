## ZombieAnims: single source of truth for all zombie animation names.
## All constants match the .res filenames in AnimationsExport/Zombies/
## Strip the .res extension to get the animation name used in AnimationPlayer.
class_name ZombieAnims

# Locomotion
const IDLE           := "Idle"
const WALK_1         := "Walk zom va1 "
const WALK_2         := "Walk zombie va2 "
const WALK_NONBINARY := "Non binary walk"
const WALK_BACKWARD  := "Back ward"

# Melee attack and grab
const ATTACK_1       := "Attack 1"  # melee swing animation
const ATTACK_2       := "Attack 2"  # melee swing animation
const GRAB_REACH   := "Zombie Attempt Grab"  # reach phase of grab
const GRAB_SUCCESS := "Zombie Grab success"  # zombie wins grab QTE
const GRAB_FAIL    := "Zombie Grab fail"     # player escapes grab
const GRAB_HOLD    := "action 2 loop"        # looping hold during QTE window

# Ranged zombie (water gun)
const RANGE_IDLE  := "Range Zombie Idle"
const RANGE_SHOOT := "Range Zombie  shot"    # two spaces match the filename

# Balloon zombie
const BALLOON_IDLE  := "Balloone Zombie Idle"
const BALLOON_THROW := "Balloone Zombie throw"

# Defeated
const DEAD      := "dEAD ZOMBIE"
const DEAD_WALK := "dEAD ZOMBIE walking"

# Body and arm hit reactions (one-shot)
const HIT_BODY      := "HIT Body"
const HIT_LEFT_ARM  := "HIT Left arm"     # lowercase a matches filename
const HIT_RIGHT_ARM := "HIT  Right Arm"   # two spaces match filename

# Head hit sequence
const HIT_HEAD_ACT1               := "HIT head act 1 - when get hit"
const HIT_HEAD_ACT2_STUN          := "HIT head act 2(Stun_idle) "
const HIT_HEAD_ACT3_TAKEDOWN      := "HIT head act 3-take down"
const HIT_HEAD_ACT4_TAKEDOWN_IDLE := "HIT head act 4 (Take_down_idle)"
const HIT_HEAD_ACT5_GETUP         := "HIT head act 5 (get_up )"

# Left leg hit sequence
const HIT_LLEG_ACT1_SLIP          := "Hit Leg act 1 Slipping"
const HIT_LLEG_ACT2_SLIP_IDLE     := "Hit Leg act 2 (Slipping_Ilde) -loop"
const HIT_LLEG_ACT3_TAKEDOWN      := "Hit Leg act 3 (Take_down) "
# Left leg shares head acts 4 and 5
const HIT_LLEG_ACT4_TAKEDOWN_IDLE := "HIT head act 4 (Take_down_idle) "
const HIT_LLEG_ACT5_GETUP         := "HIT Leg act 5 (get_up ) "

# Right leg hit sequence
const HIT_RLEG_ACT1_SLIP          := "Hit RightLeg act 1 Slipping "
const HIT_RLEG_ACT2_SLIP_IDLE     := "Hit RightLeg act 2 (Slipping_Ilde) "
const HIT_RLEG_ACT3_TAKEDOWN      := "Hit RightLeg act 3 (Take_down) "
const HIT_RLEG_ACT4_TAKEDOWN_IDLE := "HIT Rightleg act 4 (Take_down_idle) "
const HIT_RLEG_ACT5_GETUP         := "HIT Rightleg act 5 (get_up ) "

# Helpers

static func random_walk() -> String:
	return WALK_1 if randf() < 0.5 else WALK_2

static func random_attack() -> String:
	return ATTACK_1 if randf() < 0.5 else ATTACK_2

static func hit_reaction(hit_zone: String) -> String:
	match hit_zone:
		"head":      return HIT_HEAD_ACT1
		"left_leg":  return HIT_LLEG_ACT1_SLIP
		"right_leg": return HIT_RLEG_ACT1_SLIP
		"foot":      return HIT_LLEG_ACT1_SLIP
		"right_arm": return HIT_RIGHT_ARM
		"left_arm":  return HIT_LEFT_ARM
		_:           return HIT_BODY

static func stun_idle(hit_zone: String) -> String:
	match hit_zone:
		"head":              
			print(HIT_HEAD_ACT2_STUN)
			return HIT_HEAD_ACT2_STUN
		"left_leg", "foot": return HIT_LLEG_ACT2_SLIP_IDLE
		"right_leg":        return HIT_RLEG_ACT2_SLIP_IDLE
		_:                  return HIT_HEAD_ACT2_STUN

static func takedown_anim(hit_zone: String) -> String:
	match hit_zone:
		"left_leg", "foot": return HIT_LLEG_ACT3_TAKEDOWN
		"right_leg":        return HIT_RLEG_ACT3_TAKEDOWN
		_:                  return HIT_HEAD_ACT3_TAKEDOWN

static func takedown_idle(hit_zone: String) -> String:
	match hit_zone:
		"right_leg":
			return HIT_RLEG_ACT4_TAKEDOWN_IDLE
		"left_leg", "foot":
			return HIT_LLEG_ACT4_TAKEDOWN_IDLE
		"head":
			return HIT_HEAD_ACT4_TAKEDOWN_IDLE 
		_:
			return HIT_HEAD_ACT4_TAKEDOWN_IDLE


static func get_up_anim(hit_zone: String) -> String:
	return HIT_RLEG_ACT5_GETUP if hit_zone == "right_leg" else HIT_LLEG_ACT5_GETUP
