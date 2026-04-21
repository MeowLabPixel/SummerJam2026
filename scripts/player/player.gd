## Player — test controller.
## WASD movement on the XZ plane.
## Faces the mouse cursor position projected onto the ground plane.
## Belongs to the "player" group so Ashley and pickups can identify it.
class_name Player
extends CharacterBody3D

@export var move_speed: float = 5.0
@export var rotation_speed: float = 15.0

## Set by TestWorld each frame — world position of the mouse on the ground.
## Used for facing direction and as the shoot origin target.
var aim_position: Vector3 = Vector3.ZERO

# Gravity constant — keeps the player grounded on slopes.
const GRAVITY: float = -20.0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# ── Gravity ──────────────────────────────────────────────────────────
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	# ── WASD input → XZ movement ─────────────────────────────────────────
	var input_dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back")  - Input.get_action_strength("move_forward")
	)

	if input_dir.length_squared() > 0.01:
		input_dir = input_dir.normalized()
		var move_dir := Vector3(input_dir.x, 0.0, input_dir.y)
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
	else:
		# Friction — damp horizontal velocity when no input.
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	move_and_slide()

	# ── Face the mouse aim position ───────────────────────────────────────
	var to_aim: Vector3 = aim_position - global_position
	to_aim.y = 0.0
	if to_aim.length_squared() > 0.01:
		var target_basis: Basis = global_transform.looking_at(
				global_position + to_aim, Vector3.UP).basis
		global_transform.basis = global_transform.basis.slerp(
				target_basis.orthonormalized(),
				clampf(rotation_speed * delta, 0.0, 1.0))
