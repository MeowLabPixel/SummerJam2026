extends State

var half = false

func _enter() -> void:
	print(name)
	owner.qte.visible = true
	half = false
	
func _update(_delta:float) -> void:
	if owner.qte_bar.value == 100:
		finished.emit("Idle")
	if owner.start_qte:
		owner.qte_bar.value -= 1
	if owner.qte_bar.value <= 0 and owner.start_qte:
		print("lost")
		owner.HP -= 5
		#some attac anim with zombie
		finished.emit("Idle")

func _exit() -> void:
	owner.qte.visible = false
	owner.start_qte = false
	owner.qte_bar.value = 0
		
func _state_input(event: InputEvent) -> void:
	if Input.is_action_just_released("ui_left") :

		half = true
	if Input.is_action_just_released("ui_right") and half:
		if not owner.start_qte:
			owner.start_qte = true
		half = false
		owner.qte_bar.value+=20
		
