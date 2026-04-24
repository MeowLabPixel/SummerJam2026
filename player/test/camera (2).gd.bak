class_name REcamera extends Camera3D

@export var follow_player:= false
var player: Player = null

func _physics_process(delta: float) -> void:
	if follow_player and player:
		look_at(player.global_position)


func _on_trigger_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		current = true
