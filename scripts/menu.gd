extends Control

@onready var click = $Click



func _on_play_pressed():
	click.play()
	var game = get_tree().change_scene_to_file("res://scenes/main.tscn")



func _on_quit_pressed():
	click.play()
	get_tree().quit()
