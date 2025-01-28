extends Node2D

@export var value: int = 0
@onready var dano: AudioStreamPlayer2D = $Damage

func _ready():
	%Label.text = str(value)
	dano.play()
