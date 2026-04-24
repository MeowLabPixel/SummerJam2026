extends Node3D

@export_group("Gun 1 (e.g. Shotgun)")
@export var gun1_node: CollisionObject3D
@export var gun1_name: String = "Shotgun"
@export var gun1_cost: int = 50
@export var gun1_index: int = 1

@export_group("Gun 2 (e.g. Sniper)")
@export var gun2_node: CollisionObject3D
@export var gun2_name: String = "Sniper"
@export var gun2_cost: int = 100
@export var gun2_index: int = 2

@export_group("Shop Interaction")
@export var trigger_area: CollisionObject3D # The area used to press 'E'
@export var shop_camera: Node3D 

var current_player: CharacterBody3D = null

func enter_shop(player) -> bool:
	current_player = player
	current_player.is_in_shop = true
	current_player.current_shop = self
	
	var sm = current_player.get_node_or_null("Statemachine")
	if sm: sm.set_physics_process(false)
	
	# --- CAMERA LOGIC ---
	# Find the Player's PhantomCamera3D in the world to lower its priority
	var player_pcam = null
	for node in get_tree().get_nodes_in_group("phantom_camera_group"):
		if "Player" in node.name or "PhantomCamera3D" in node.name:
			player_pcam = node
			break
	
	if player_pcam and player_pcam.has_method("set_priority"):
		player_pcam.call("set_priority", 0)
		
	if shop_camera and shop_camera.has_method("set_priority"):
		shop_camera.call("set_priority", 100) # Higher than default player camera
	elif shop_camera is Camera3D:
		shop_camera.make_current()
	# --------------------
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Entered Gun Shop")
	return true

func exit_shop():
	if not current_player: return
	current_player.is_in_shop = false
	current_player.current_shop = null
	
	var sm = current_player.get_node_or_null("Statemachine")
	if sm: sm.set_physics_process(true)
	
	# --- CAMERA LOGIC ---
	# Reset priorities
	if shop_camera and shop_camera.has_method("set_priority"):
		shop_camera.call("set_priority", 0)
		
	var player_pcam = null
	for node in get_tree().get_nodes_in_group("phantom_camera_group"):
		if "Player" in node.name or "PhantomCamera3D" in node.name:
			player_pcam = node
			break
				
	if player_pcam and player_pcam.has_method("set_priority"):
		player_pcam.call("set_priority", 10) # Restore player priority
	# --------------------
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_player = null
	print("Exited Shop")

func interact(hit_node: Node) -> bool:
	if not current_player: return false
	
	print("[Shop Debug] Clicked on node: ", hit_node.name)

	if hit_node == gun1_node:
		print("[Shop Debug] Identified as Gun 1: ", gun1_name)
		return _process_purchase(gun1_name, gun1_cost, gun1_index)
	elif hit_node == gun2_node:
		print("[Shop Debug] Identified as Gun 2: ", gun2_name)
		return _process_purchase(gun2_name, gun2_cost, gun2_index)
	
	print("[Shop Debug] Node clicked is not assigned as Gun 1 or Gun 2.")
	return false

func _process_purchase(g_name: String, g_cost: int, g_index: int) -> bool:
	# Check if already unlocked
	if current_player.gun_controller.unlocked_guns[g_index]:
		print(g_name, " is already unlocked! Switching...")
		current_player.gun_controller.switch_gun(g_index)
		return true

	if ItemManager.get_coins() >= g_cost:
		ItemManager.spend_coins(g_cost)
		print("Bought ", g_name, " for ", g_cost)
		current_player.gun_controller.unlock_gun(g_index)
		current_player.gun_controller.switch_gun(g_index)
		return true
	else:
		print("Not enough coins for ", g_name, "! Need ", g_cost)
		return false
