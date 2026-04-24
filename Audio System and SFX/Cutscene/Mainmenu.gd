extends Control

@onready var play_btn := $MenuContainer/VBoxContainer/PlayButton
@onready var settings_btn := $MenuContainer/VBoxContainer/SettingsButton
@onready var quit_btn := $MenuContainer/VBoxContainer/QuitButton
@onready var title := $MenuContainer/VBoxContainer/Title
@onready var anim := $MenuContainer/VBoxContainer/QuitButton/MainMenu/CutScene1/Cutscene1/AnimationPlayer

func _ready() -> void:
	# Set up ping-pong animation for main menu idle loop
	anim.play("Mainmenu start")
	print("[MainMenu] Playing Mainmenu start animation in ping-pong mode")
	
	# Apply liquid glass shader to all buttons
	_apply_glass_shader(play_btn)
	_apply_glass_shader(settings_btn)
	_apply_glass_shader(quit_btn)
	
	# Style title
	var title_font = title.get_theme_font("font")
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	
	# Style button labels
	for button in [play_btn, settings_btn, quit_btn]:
		var label = button.get_node("Label")
		label.add_theme_font_size_override("font_size", 28)
		label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	
	# Connect button signals
	play_btn.gui_input.connect(_on_play_input)
	settings_btn.gui_input.connect(_on_settings_input)
	quit_btn.gui_input.connect(_on_quit_input)
	
	# Hover animations
	play_btn.mouse_entered.connect(func(): _on_button_hover(play_btn, true))
	play_btn.mouse_exited.connect(func(): _on_button_hover(play_btn, false))
	settings_btn.mouse_entered.connect(func(): _on_button_hover(settings_btn, true))
	settings_btn.mouse_exited.connect(func(): _on_button_hover(settings_btn, false))
	quit_btn.mouse_entered.connect(func(): _on_button_hover(quit_btn, true))
	quit_btn.mouse_exited.connect(func(): _on_button_hover(quit_btn, false))

func _apply_glass_shader(panel: Panel) -> void:
	var shader_material = ShaderMaterial.new()
	var shader = load("res://Audio System and SFX/Cutscene/liquid_glass.gdshader")
	shader_material.shader = shader
	
	# Customize shader parameters for nice glass effect
	shader_material.set_shader_parameter("blur", 3.5)
	shader_material.set_shader_parameter("warp_intensity", 0.35)
	shader_material.set_shader_parameter("corner_radius", 0.15)
	shader_material.set_shader_parameter("tint", Color(0.95, 0.97, 1.0, 0.15))
	shader_material.set_shader_parameter("edge_highlight", Color(1.0, 1.0, 1.0, 0.4))
	shader_material.set_shader_parameter("chromatic_strength", 3.0)
	
	panel.material = shader_material

func _on_button_hover(button: Panel, hovered: bool) -> void:
	var tween = create_tween().set_parallel(true)
	
	if hovered:
		# UI sound
		AudioManager.play_random_ui.emit("button")
		# Scale up slightly
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# Intensify glass effect
		if button.material:
			tween.tween_property(button.material, "shader_parameter/tint", Color(0.95, 0.97, 1.0, 0.25), 0.2)
	else:
		# Scale back
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		# Reset glass
		if button.material:
			tween.tween_property(button.material, "shader_parameter/tint", Color(0.95, 0.97, 1.0, 0.15), 0.2)

func _on_play_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		AudioManager.play_random_ui.emit("button")
		print("[MainMenu] Play clicked - starting cutscene animation...")
		
		# Stop the menu loop animation
		if anim:
			anim.stop()
		
		# Hide menu UI
		$MenuContainer.visible = false
		
		# Start the cutscene animation
		if anim and anim.has_animation("FullCutscene"):
			anim.play("FullCutscene")
			print("[MainMenu] Playing FullCutscene animation")
		else:
			push_error("[MainMenu] FullCutscene animation not found!")

func _on_settings_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		AudioManager.play_random_ui.emit("button")
		print("[MainMenu] Settings clicked")
		# Load settings scene
		# get_tree().change_scene_to_file("res://Scenes/Settings.tscn")

func _on_quit_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		AudioManager.play_random_ui.emit("button")
		print("[MainMenu] Quit clicked")
		get_tree().quit()
