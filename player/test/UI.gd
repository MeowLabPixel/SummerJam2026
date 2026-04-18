extends CanvasLayer

@export var ammo: Label 
@export var player: Player 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ammo.text = "Air: "+ str(player.Ammo)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ammo.text = "Air: "+ str(player.Ammo)
