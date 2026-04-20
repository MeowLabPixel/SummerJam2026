extends CanvasLayer

@export var ammo: Label 
@export var player: Player 
@onready var hp: Label = $HP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ammo.text = "Air: "+ str(player.curr_gun.ammo)
	hp.text = "HP: " + str(player.HP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.HP <=0:
		self.visible = false
	ammo.text = "Air: "+ str(player.curr_gun.ammo)
	hp.text = "HP: " + str(player.HP)
