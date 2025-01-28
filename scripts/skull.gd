extends Sprite2D

@onready var death: AudioStreamPlayer2D = $Death


# Called when the node enters the scene tree for the first time.
func _ready():
	death.play()
