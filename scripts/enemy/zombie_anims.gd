## ZombieAnims: single source of truth for all zombie animation names.
## Every enemy state imports this so animation name changes only need
## to happen in one place.
class_name ZombieAnims

# Locomotion
const IDLE   := "Idle"
const WALK_1 := "Walk zom va1 "
const WALK_2 := "Walk zombie va2 "
const WALK_3 := "Non binary walk"

# Standard attacks (one-shot, play then return to Hunt)
const ATTACK_1 := "Attack 1"
const ATTACK_2  := "Attack 2"


# Grab sequence (three-phase)
## Phase 1: zombie lunges / reaches toward the player.
const GRAB_REACH   := "Zombie Attempt Grab"
## Phase 2: zombie locks on (loops while QTE is active).
const GRAB_HOLD    := "Zombie Grab success"
## Phase 3a: bite/damage — QTE failed, zombie wins.
const GRAB_SUCCESS := "Zombie Grab success"
## Phase 3b: player shook free — QTE succeeded.
const GRAB_FAIL    := "Zombie Grab fail"

# Hit reactions (one-shot, play-and-return)
const HIT_BODY      := "HIT Body"
const HIT_RIGHT_ARM := "HIT  Right Arm"
const HIT_LEFT_ARM  := "HIT Left arm"
## Act 1: initial jerk when a head/foot shot lands.
const HIT_HEAD_ACT1 := "HIT head act 1 - when get hit"

# Head/Foot stun states (looping)
## Act 2: looping stun-idle while the zombie is TAKEDOWNable.
const HIT_HEAD_ACT2_STUN_IDLE    := "HIT head act 2(Stun_idle) "  # trailing space is intentional
## Act 3: transition animation into takedown fall.
const HIT_HEAD_ACT3_TAKEDOWN      := "HIT head act 3-take down"
## Act 4: idle loop on the ground while takedown executes.
const HIT_HEAD_ACT4_TAKEDOWN_IDLE := "HIT head act 4 (Take_down_idle)"

const HIT_HEAD_ACT5_GET_UP := "HIT head act 5 (get_up )"

# Helpers

## Returns a random walk animation name (50/50 between the two walk variants).
static func random_walk() -> String:
	return WALK_1 if randf() < 0.5 else WALK_2

## Returns a random standard-attack animation.
static func random_attack() -> String:
	var roll := randf()
	if roll < 0.5:
		return ATTACK_1
	else:
		return ATTACK_2

## Returns the appropriate one-shot hit-reaction animation for a given zone_name.
static func hit_reaction(hit_zone: String) -> String:
	match hit_zone:
		"head", "foot":
			return HIT_HEAD_ACT1
		"right_arm":
			return HIT_RIGHT_ARM
		"left_arm":
			return HIT_LEFT_ARM
		_:
			return HIT_BODY
