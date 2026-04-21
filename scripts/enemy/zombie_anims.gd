## ZombieAnims: single source of truth for all zombie animation names.
## Every enemy state imports this so animation name changes only need
## to happen in one place.
class_name ZombieAnims

# ─── Locomotion ───────────────────────────────────────────────────────────
const IDLE     := "Idle"
const WALK_1   := "Walk zom va1 "
const WALK_2   := "Walk zombie va2 "

# ─── Hit reactions (one-shot, play-and-return) ────────────────────────────
const HIT_BODY      := "HIT Body"
const HIT_RIGHT_ARM := "HIT  Right Arm"
const HIT_LEFT_ARM  := "HIT Left arm"
## Act 1 = the initial jerk when a head/foot shot lands.
const HIT_HEAD_ACT1 := "HIT head act 1 - when get hit"

# ─── Head/Foot stun states (looping) ─────────────────────────────────────
## Act 2 = the idle stun loop while the zombie is TAKEDOWNable.
const HIT_HEAD_ACT2_STUN_IDLE := "HIT head act 2(Stun_idle) "  # Note trailing space in GLB name.
## Act 3 = the transition animation into takedown.
const HIT_HEAD_ACT3_TAKEDOWN  := "HIT head act 3-take down"
## Act 4 = the idle loop while the takedown is being executed.
const HIT_HEAD_ACT4_TAKEDOWN_IDLE := "HIT head act 4 (Take_down_idle)"

# ─── Helper: pick a random walk variant ──────────────────────────────────
static func random_walk() -> String:
	return WALK_1 if randf() < 0.5 else WALK_2

# ─── Helper: pick hit reaction from hit_zone string ──────────────────────
## Returns the one-shot hit reaction anim for the given zone.
## "head" and "foot" use the head act 1 jerk.
## "body", "right_arm", "left_arm" use their respective reactions.
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
