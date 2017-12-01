extends Node2D

var player_1 = "p1"
var player_2 = "p2"
var player_label
var sprite
var animation_player

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://game.tscn")
	
func _ready():
	set_process_input(true)
	player_label = get_node("PlayerLabel")
	sprite = get_node("Sprite")
	animation_player = sprite.get_node("AnimationPlayer")
	if global.loser == player_1:
		player_label.set_text("Player " + str(2))
		animation_player.play("animation_girl_cheer")
	elif global.loser == player_2:
		player_label.set_text("Player " + str(1))
		animation_player.play("animation_boy_cheer")
	else:
		player_label.set_text("Player 1/2")
		animation_player.play("animation_boy_cheer")