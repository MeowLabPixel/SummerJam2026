@tool
extends Node3D

@export var emitting: bool:
	get:
		return false
	set(value):
		if value and is_inside_tree():
			call_deferred("_trigger_emit")

var _busy := false

@onready var _pulse_core: MeshInstance3D = get_node_or_null("PulseCore")
@onready var _shockwave_shell: MeshInstance3D = get_node_or_null("ShockwaveShell")
@onready var _flash_light: OmniLight3D = get_node_or_null("FlashLight")

func _ready() -> void:
	if _pulse_core:
		_pulse_core.visible = false
	if _shockwave_shell:
		_shockwave_shell.visible = false
	if _flash_light:
		_flash_light.light_energy = 0.0

func _trigger_emit() -> void:
	if _busy:
		return

	_busy = true
	_restart_particles()
	_play_mesh_pulses()
	_play_light_pulse()

	await get_tree().create_timer(1.6).timeout

	for particle in _get_particles():
		particle.emitting = false

	if _pulse_core:
		_pulse_core.visible = false
	if _shockwave_shell:
		_shockwave_shell.visible = false
	if _flash_light:
		_flash_light.light_energy = 0.0

	_busy = false
	notify_property_list_changed()

func _restart_particles() -> void:
	for particle in _get_particles():
		particle.emitting = false
		particle.restart()
		particle.emitting = true

func _play_mesh_pulses() -> void:
	if _pulse_core:
		_pulse_core.visible = true
		_pulse_core.scale = Vector3.ONE * 0.22
		var core_tween := create_tween()
		core_tween.tween_property(_pulse_core, "scale", Vector3.ONE * 0.95, 0.14).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		core_tween.tween_property(_pulse_core, "scale", Vector3.ONE * 0.02, 0.55).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		core_tween.finished.connect(func() -> void:
			if is_instance_valid(_pulse_core):
				_pulse_core.visible = false
		)

	if _shockwave_shell:
		_shockwave_shell.visible = true
		_shockwave_shell.scale = Vector3(0.18, 0.05, 0.18)
		var shell_tween := create_tween()
		shell_tween.tween_property(_shockwave_shell, "scale", Vector3(2.4, 0.12, 2.4), 0.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		shell_tween.tween_property(_shockwave_shell, "scale", Vector3(2.9, 0.01, 2.9), 0.20).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
		shell_tween.finished.connect(func() -> void:
			if is_instance_valid(_shockwave_shell):
				_shockwave_shell.visible = false
		)

func _play_light_pulse() -> void:
	if not _flash_light:
		return

	_flash_light.light_energy = 0.0
	var light_tween := create_tween()
	light_tween.tween_property(_flash_light, "light_energy", 2.6, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	light_tween.tween_property(_flash_light, "light_energy", 0.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _get_particles() -> Array[GPUParticles3D]:
	var particles: Array[GPUParticles3D] = []
	_collect_particles(self, particles)
	return particles

func _collect_particles(node: Node, particles: Array[GPUParticles3D]) -> void:
	for child in node.get_children():
		if child is GPUParticles3D:
			particles.append(child)
		_collect_particles(child, particles)
