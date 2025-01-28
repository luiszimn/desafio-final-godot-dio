extends Node2D


var damage_amount: int = 1

@onready var area2D: Area2D = $Area2D
@onready var ritual: AudioStreamPlayer2D = $Ritual



func deal_damage():
	ritual.play()
	var bodies = area2D.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			enemy.damage(damage_amount)
			
