## STATE: Attack / Grab
## Enemy is in attack range and facing the player.
## Mostly attacks; small random chance to grab instead.
class_name StateAttack
extends EnemyState

## Probability (0–1) of choosing Grab over Attack.
@export var grab_chance: float = 0.15
## How long the attack animation plays before returning to Hunt.
@export var attack_duration: float = 1.2

var _timer: float = 0.0
var _chose_grab: bool = false

func enter() -> void:
	_timer = 0.0
	_chose_grab = randf() < grab_chance
	if _chose_grab:
		print("[StateAttack] Chose GRAB.")
		# TODO: play grab animation, enable grab hitbox.
	else:
		print("[StateAttack] Chose ATTACK.")
		# TODO: play attack animation, enable attack hitbox.

func exit() -> void:
	# TODO: disable hitboxes.
	pass

func physics_update(delta: float) -> void:
	_timer += delta
	if _timer >= attack_duration:
		# Return to Hunt after the swing is done.
		state_machine.transition_to("StateHunt")

func handle_hit(hit_data: Dictionary) -> String:
	# Being hit while attacking interrupts only on head/foot.
	var zone: String = hit_data.get("hit_zone", "body")
	match zone:
		"head", "foot":
			return "StateTakedownable"
		_:
			return ""  # Body hits don't interrupt an attack in progress.
