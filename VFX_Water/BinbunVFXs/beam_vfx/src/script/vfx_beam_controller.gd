@tool
extends Node3D


var beam_pivot : Node3D
var beam_end_pivot : Node3D
var beam_scalor : Node3D

var beam_core : MeshInstance3D
var beam_outer : MeshInstance3D
var beam_start : MeshInstance3D
var beam_flare1 : MeshInstance3D
var beam_flare2 : MeshInstance3D
var beam_end : MeshInstance3D

var audio_start : AudioStreamPlayer3D:
	get():
		if !Engine.is_editor_hint():
			if !audio_start:
				var result = $AudioStart
				audio_start = result
			return audio_start
		else:
			return $AudioStart
var audio_mid : AudioStreamPlayer3D:
	get():
		if !Engine.is_editor_hint():
			if !audio_mid:
				var result = $BeamPivot/BeamScalor/AudioMid
				audio_mid = result
			return audio_mid
		else:
			return $BeamPivot/BeamScalor/AudioMid
var audio_end : AudioStreamPlayer3D:
	get():
		if !Engine.is_editor_hint():
			if !audio_end:
				var result = $BeamEndPivot/AudioEnd
				audio_end = result
			return audio_end
		else:
			return $BeamEndPivot/AudioEnd

var beam_particles : GPUParticles3D
var beam_end_particles : GPUParticles3D

@export_group("Color")

@export var primary_color : Color:
	set(v):
		primary_color = v
		_set_shader_param("primary_color", primary_color)

@export var secondary_color : Color:
	set(v):
		secondary_color = v
		_set_shader_param("secondary_color", secondary_color)

@export var tertiary_color : Color:
	set(v):
		tertiary_color = v
		_set_shader_param("tertiary_color", tertiary_color)

@export var emission : float = 3.0:
	set(v):
		emission = v
		_set_shader_param("emission", emission)

@export_group("Noise")

@export var noise_texture : Texture2D:
	set(v):
		noise_texture = v
		_set_shader_param("noise_texture", noise_texture)

@export var noise_twist : float = 3.0:
	set(v):
		noise_twist = v
		_set_shader_param("noise_twist", noise_twist)

@export var scroll_speed : Vector2 = Vector2(0.0,1.0):
	set(v):
		scroll_speed = v
		_set_shader_param("scroll_speed", scroll_speed)

@export_group("Shape")

@export var beam_radius : float = 0.2:
	set(v):
		beam_radius = v
		if beam_core and beam_outer and beam_end and beam_particles:
			beam_core.mesh.top_radius = beam_radius
			beam_core.mesh.bottom_radius = beam_radius
			beam_outer.mesh.top_radius = beam_radius + 0.05
			beam_outer.mesh.bottom_radius = beam_radius + 0.05
			
			beam_end.mesh.radius = beam_radius + 0.2
			beam_end.mesh.height = (beam_radius + 0.2) * 2.0
			
			beam_particles.process_material.emission_sphere_radius = beam_radius + 0.1

@export var start_radius : float = 0.3:
	set(v):
		start_radius = v
		if beam_flare1 and beam_flare2 and beam_start:
			
			beam_flare1.mesh.top_radius = start_radius
			
			beam_flare2.mesh.top_radius = start_radius
			
			beam_start.mesh.radius = start_radius
			beam_start.mesh.height = start_radius * 2.0
			
			start_flare = start_flare

@export var start_flare : float = 0.2:
	set(v):
		start_flare = v
		if beam_flare1 and beam_flare2:
			beam_flare1.mesh.bottom_radius = start_radius * (1.0 + start_flare)
			beam_flare2.mesh.bottom_radius = start_radius * (1.5 + start_flare)

@export var edge_softness : float = 0.5:
	set(v):
		edge_softness = v
		_set_shader_param("edge_softness", edge_softness)

@export var enable_end : bool = true:
	set(v):
		enable_end = v
		beam_end_pivot.visible = enable_end

@export_group("Pulse")

@export var pulse_strength : float = 0.05:
	set(v):
		pulse_strength = v
		_set_shader_param("pulse_strength", pulse_strength)

@export var pulse_frequency : float = 30.0:
	set(v):
		pulse_frequency = v
		_set_shader_param("pulse_frequency", pulse_frequency)

@export var pulse_speed : float = 30.0:
	set(v):
		pulse_speed = v
		_set_shader_param("pulse_speed", pulse_speed)

@export_group("Particles")

@export var start_emitting : bool = true:
	set(v):
		start_emitting = v
		if beam_particles:
			beam_particles.emitting = start_emitting

@export var start_amount : int = 64:
	set(v):
		start_amount = v
		if beam_particles:
			beam_particles.amount = start_amount

@export var end_emitting : bool = true:
	set(v):
		end_emitting = v
		if beam_end_particles:
			beam_end_particles.emitting = end_emitting

@export var end_amount : int = 64:
	set(v):
		end_amount = v
		if beam_end_particles:
			beam_end_particles.amount = end_amount

@export_group("Follow")

var materials : Array[ShaderMaterial] = []

@export var preview : bool:
	set(v):
		preview = v

@export var end_point : Node3D:
	set(v):
		end_point = v
		if !end_point:
			_reset_pivot()

@export var beam_length : float = 4.0:
	set(v):
		beam_length = v
		if !end_point:
			_reset_pivot()

var length : float = 4.0

@export_group("Animation")

@export_range(0.0, 1.0, 0.01) var open_amount = 1.0:
	set(v):
		open_amount = v
		_set_shader_param("open_amount", open_amount)
		_set_open_amount()
		_set_buildup_amount()

@export_group("Audio")
@export var audio_start_stream : AudioStream:
	set(v):
		audio_start_stream = v
		if audio_start:
			audio_start.stream = audio_start_stream
@export var audio_mid_stream : AudioStream:
	set(v):
		audio_mid_stream = v
		if audio_mid:
			audio_mid.stream = audio_mid_stream
@export var audio_end_stream : AudioStream:
	set(v):
		audio_end_stream = v
		if audio_end:
			audio_end.stream = audio_end_stream
@export_range(-80.0, 80.0, 0.01) var volume_db : float = 0.0:
	set(v):
		volume_db = v
		if audio_start: audio_start.volume_db = volume_db
		if audio_mid: audio_mid.volume_db = volume_db
		if audio_end: audio_end.volume_db = volume_db
@export_range(0.1, 100.0, 0.01) var unit_size : float = 10.0:
	set(v):
		unit_size = v
		if audio_start: audio_start.unit_size = unit_size
		if audio_mid: audio_mid.unit_size = unit_size
		if audio_end: audio_end.unit_size = unit_size
@export_range(-24.0, 6.0, 0.01) var max_db : float = 3.0:
	set(v):
		max_db = v
		if audio_start: audio_start.max_db = max_db
		if audio_mid: audio_mid.max_db = max_db
		if audio_end: audio_end.max_db = max_db
@export_range(0.01, 4.0, 0.01) var pitch_scale : float = 1.0:
	set(v):
		pitch_scale = v
		if audio_start: audio_start.pitch_scale = pitch_scale
		if audio_mid: audio_mid.pitch_scale = pitch_scale
		if audio_end: audio_end.pitch_scale = pitch_scale
@export var audio_playing : bool = false:
	set(v):
		audio_playing = v
		if audio_start: audio_start.playing = audio_playing
		if audio_mid: audio_mid.playing = audio_playing
		if audio_end: audio_end.playing = audio_playing
@export var audio_autoplay : bool = false:
	set(v):
		audio_autoplay = v
		if audio_start: audio_start.autoplay = audio_autoplay
		if audio_mid: audio_mid.autoplay = audio_autoplay
		if audio_end: audio_end.autoplay = audio_autoplay
@export var audio_stream_paused : bool = false:
	set(v):
		audio_stream_paused = v
		if audio_start: audio_start.stream_paused = audio_stream_paused
		if audio_mid: audio_mid.stream_paused = audio_stream_paused
		if audio_end: audio_end.stream_paused = audio_stream_paused
@export_range(0.0, 4000.0, 0.01) var max_distance : float = 0.0:
	set(v):
		max_distance = v
		if audio_start: audio_start.max_distance = max_distance
		if audio_mid: audio_mid.max_distance = max_distance
		if audio_end: audio_end.max_distance = max_distance
@export var audio_bus : StringName = &"Master":
	set(v):
		audio_bus = v
		if audio_start: audio_start.bus = audio_bus
		if audio_mid: audio_mid.bus = audio_bus
		if audio_end: audio_end.bus = audio_bus

func _physics_process(delta: float) -> void:
	if end_point:
		follow_node()

func _ready() -> void:
	_setup_effect()

func _enter_tree() -> void:
	_setup_effect()

func follow_node() -> void:
	if !Engine.is_editor_hint() || preview:
		var end_pos = end_point.global_position
		beam_pivot.look_at(end_point.global_position)
		
		length = global_position.distance_to(end_pos)
		beam_scalor.scale.z = length * open_amount
		
		beam_end_pivot.rotation = beam_pivot.rotation
		
		beam_end_pivot.global_position = end_pos

func _set_open_amount() -> void:
	beam_scalor.scale.z = beam_length * open_amount
	
	if open_amount == 0.0:
		beam_scalor.hide()
	else:
		if !beam_scalor.visible:
			beam_scalor.show()
		
		beam_particles.emitting = open_amount > 0.8
		
		beam_pivot.scale.x = pow(open_amount, 0.5)
		beam_pivot.scale.y = pow(open_amount, 0.5)
		
		if open_amount == 1.0:
			enable_end = true
		else:
			enable_end = false

func _set_buildup_amount() -> void:
	if open_amount == 0.0:
		beam_start.hide()
	else:
		if !beam_start.visible:
			beam_start.show()
			
		var flash_amount = 1.0 - abs(open_amount * 2.0 - 1.0)
		beam_start.material_override.set_shader_parameter("flash_amount", flash_amount)
		beam_start.scale = Vector3(open_amount,open_amount,open_amount) + (Vector3(1.0,1.0,1.0) * pow(flash_amount, 0.5))

func _setup_effect() -> void:
	if !beam_pivot:
		beam_pivot = $BeamPivot
	if !beam_scalor:
		beam_scalor = $BeamPivot/BeamScalor
	if !beam_end_pivot:
		beam_end_pivot = $BeamEndPivot
	
	if !beam_core:
		beam_core = $BeamPivot/BeamScalor/BeamCore
		materials.append(beam_core.material_override)
	if !beam_outer:
		beam_outer = $BeamPivot/BeamScalor/BeamOuter
		materials.append(beam_outer.material_override)
	if !beam_start:
		beam_start = $BeamStart
		materials.append(beam_start.material_override)
	if !beam_flare1:
		beam_flare1 = $BeamPivot/BeamFlare1
		materials.append(beam_flare1.material_override)
	if !beam_flare2:
		beam_flare2 = $BeamPivot/BeamFlare2
		materials.append(beam_flare2.material_override)
	if !beam_particles:
		beam_particles = $BeamPivot/BeamParticles
		materials.append(beam_particles.material_override)
	if !beam_end:
		beam_end = $BeamEndPivot/BeamEnd
		materials.append(beam_end.material_override)
	if !beam_end_particles:
		beam_end_particles = $BeamEndPivot/BeamEndParticles
		materials.append(beam_end_particles.material_override)

func _reset_pivot() -> void:
	if beam_pivot and beam_scalor and beam_end_pivot:
		beam_pivot.rotation = Vector3()
		beam_scalor.scale.z = beam_length * open_amount
		beam_end_pivot.position = Vector3(0.0,0.0,-beam_length)
		beam_end_pivot.rotation = Vector3()
		length = beam_length

func _set_shader_param(key : String, value : Variant) -> void:
	for m in materials:
		m.set_shader_parameter(key, value)
