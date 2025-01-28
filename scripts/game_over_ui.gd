class_name GameOverUI
extends CanvasLayer


@onready var time_label: Label = %TimeLabel
@onready var monsters_label: Label = %MonstersLabel
@onready var end_game = $GameOver
@onready var click = $Click


@export var restart_delay: float = 5.0
var restart_cooldown: float


func _ready():
	time_label.text = GameManager.time_elapsed_string
	end_game.play()
	monsters_label.text = str(GameManager.monsters_defeat_counter)
	restart_cooldown = restart_delay


func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()


func _on_exit_pressed() -> void:
	click.play()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")



func _on_reset_pressed() -> void:
	click.play() 
	restart_game()
	
	
