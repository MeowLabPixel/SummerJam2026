## ZombieAnims: single source of truth for all zombie animation names.
## Every enemy state imports this so animation name changes only need
## to happen in one place.
class_name ZombieAnims

# ─── Locomotion ───────────────────────────────────────────────────────────
const IDLE           := "Idle"
const WALK_1         := "Walk zom va1 "       # trailing space is in GLB
const WALK_2         := "Walk zombie va2 "    # trailing space is in GLB
const WALK_3         := "Non binary walk"

# ─── Hit reactions (one-shot, play-and-return) ────────────────────────────
const HIT_BODY      := "HIT Body"
const HIT_RIGHT_ARM := "HIT Right Arm"
const HIT_LEFT_ARM  := "HIT Left arm"
## Act 1 = the initial jerk when a head/foot shot lands.
const HIT_HEAD_ACT1 := "HIT head act 1 - when get hit"

# ─── Head/Foot stun chain (looping states) ───────────────────────────────
## Act 2 = stun-idle loop while TAKEDOWNable.
const HIT_HEAD_ACT2_STUN_IDLE     := "HIT head act 2(Stun_idle) "  # trailing space in GLB
## Act 3 = transition into takedown.
const HIT_HEAD_ACT3_TAKEDOWN      := "HIT head act 3-take down"
## Act 4 = idle loop while takedown executes.
const HIT_HEAD_ACT4_TAKEDOWN_IDLE := "HIT head act 4 (Take_down_idle)"
## Act 5 = get-up after knockdown.
const HIT_HEAD_ACT5_GET_UP        := "HIT head act 5 (get_up )"

# ─── Grab (zombie side) ───────────────────────────────────────────────────
const ZOMBIE_ATTEMPT_GRAB  := "Zombie Attempt Grab"
const ZOMBIE_GRAB_FAIL     := "Zombie Grab fail"
const ZOMBIE_GRAB_SUCCESS  := "Zombie Grab success"

# ─── Grab reactions (player/Leon side — played on the zombie rig) ─────────
const LEON_GRAB_FAIL    := "LEON GRAB Fail"
const LEON_GRAB_SUCCESS := "LEON GRAB Sucess"   # note: GLB has typo 'Sucess'

# ─── Helper: pick a random walk variant ──────────────────────────────────
static func random_walk() -> String:
	var r := randi() % 3
	match r:
		0: return WALK_1
		1: return WALK_2
		_: return WALK_3

# ─── Helper: pick hit reaction from hit_zone string ──────────────────────
## Returns the one-shot hit reaction anim for the given zone.
## "head" and "foot" route to the head act 1 jerk.
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
