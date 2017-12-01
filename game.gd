extends Node2D

var playfield_1
var playfield_2

var player_1 = "p1"
var player_2 = "p2"

var upcoming_set_size = 9002

var balls_types_set_history = []

var playfield_1_set_index = -1
var playfield_2_set_index = -1

var TYPE_NORMAL
var TYPE_THROW
var SPORT_SOCCER
var SPORT_BASKET
var SPORT_BOWLING
var SPORT_FOOTBALL
var SPORT_TENNIS
var SPORT_RUBBISH

var soccer_ball_texture
var soccer_ball_throw_texture
var basket_ball_texture
var basket_ball_throw_texture
var bowling_ball_texture
var bowling_ball_throw_texture
var football_ball_texture
var football_ball_throw_texture
var tennis_ball_texture
var tennis_ball_throw_texture
var rubbish_ball_texture

var next_parent_1
var next_child_1
var next_parent_2
var next_child_2

var chain_label_1
var chain_label_2

var chain_label_1_time = 120
var chain_label_2_time = 120
var chain_label_1_count = chain_label_1_time
var chain_label_2_count = chain_label_2_time

var warning_label_1
var warning_label_2

var player_1_sprite
var player_2_sprite

var player_1_animation
var player_2_animation

var anim_cheer = "Cheer"
var anim_hurt = "Hurt"
var anim_idle = "Idle"
var anim_kick = "Kick"

var sample_player
var sound_anti_clockwise = "anti_clockwise"
var sound_clockwise = "clockwise"
var sound_drop = "drop"
var sound_rubbish = "rubbish"
var sound_throw = "throw"

func generate_random_numbers(from, to, number_of_times):
	var n
	var result = []
	for _ in range(number_of_times):
		n = int(rand_range(from, to + 1))
		result.append(n)
	return result
	
func add_new_set_to_history():
	var upcoming_balls = generate_random_numbers(1, 5, upcoming_set_size)
	var upcoming_types = generate_random_numbers(1, 100, upcoming_set_size)
	var upcoming_balls_types = []
	for i in range(upcoming_balls.size()):
		upcoming_balls_types.append([upcoming_balls[i], upcoming_types[i]])
	balls_types_set_history.append(upcoming_balls_types)
	
func update_playfield_upcoming_balls_types(playfield):
	var name = playfield.get_name()
	var playfield_set_index
	if name == "Playfield1":
		playfield_set_index = playfield_1_set_index
	else:
		playfield_set_index = playfield_2_set_index
	
	playfield_set_index += 1
	if playfield_set_index >= balls_types_set_history.size():
		add_new_set_to_history()
	playfield.upcoming_balls_types = [] + balls_types_set_history[playfield_set_index]
		
func send_attack_to_other_player(player_assign, attack):
	if player_assign == player_1:
		playfield_2.add_rubbish(attack)
	else:
		playfield_1.add_rubbish(attack)
		
func update_next_next_balls(player_assign):
	var next_parent
	var next_child
	var playfield
	var next_parent_sprite
	var next_child_sprite
	var next_parent_texture
	var next_child_texture
	if player_assign == player_1:
		playfield = playfield_1
		next_parent_sprite = next_parent_1
		next_child_sprite = next_child_1
	else:
		playfield = playfield_2
		next_parent_sprite = next_parent_2
		next_child_sprite = next_child_2
		
	next_parent = playfield.next_next_ball_parent
	next_child = playfield.next_next_ball_child
	
	var next_parent_ball = next_parent[0]
	var next_parent_type = next_parent[1]
	var next_child_ball = next_child[0]
	var next_child_type = next_child[1]
	
	if next_parent_ball == SPORT_SOCCER:
		if next_parent_type == TYPE_THROW:
			next_parent_texture = soccer_ball_throw_texture
		else:
			next_parent_texture = soccer_ball_texture
	elif next_parent_ball == SPORT_BASKET:
		if next_parent_type == TYPE_THROW:
			next_parent_texture = basket_ball_throw_texture
		else:
			next_parent_texture = basket_ball_texture
	elif next_parent_ball == SPORT_BOWLING:
		if next_parent_type == TYPE_THROW:
			next_parent_texture = bowling_ball_throw_texture
		else:
			next_parent_texture = bowling_ball_texture
	elif next_parent_ball == SPORT_FOOTBALL:
		if next_parent_type == TYPE_THROW:
			next_parent_texture = football_ball_throw_texture
		else:
			next_parent_texture = football_ball_texture
	elif next_parent_ball == SPORT_TENNIS:
		if next_parent_type == TYPE_THROW:
			next_parent_texture = tennis_ball_throw_texture
		else:
			next_parent_texture = tennis_ball_texture

	if next_child_ball == SPORT_SOCCER:
		if next_child_type == TYPE_THROW:
			next_child_texture = soccer_ball_throw_texture
		else:
			next_child_texture = soccer_ball_texture
	elif next_child_ball == SPORT_BASKET:
		if next_child_type == TYPE_THROW:
			next_child_texture = basket_ball_throw_texture
		else:
			next_child_texture = basket_ball_texture
	elif next_child_ball == SPORT_BOWLING:
		if next_child_type == TYPE_THROW:
			next_child_texture = bowling_ball_throw_texture
		else:
			next_child_texture = bowling_ball_texture
	elif next_child_ball == SPORT_FOOTBALL:
		if next_child_type == TYPE_THROW:
			next_child_texture = football_ball_throw_texture
		else:
			next_child_texture = football_ball_texture
	elif next_child_ball == SPORT_TENNIS:
		if next_child_type == TYPE_THROW:
			next_child_texture = tennis_ball_throw_texture
		else:
			next_child_texture = tennis_ball_texture
			
	next_parent_sprite.set_texture(next_parent_texture)
	next_child_sprite.set_texture(next_child_texture)
	
func display_chain(player_assign, n):
	if player_assign == player_1:
		chain_label_1.set_text(str(n) + " chain!")
		chain_label_1_count = 0
	else:
		chain_label_2.set_text(str(n) + " chain!")
		chain_label_2_count = 0
		
func display_warning(player_assign, n):
	if player_assign == player_1:
		warning_label_1.set_text("Warning: " + str(n))
	else:
		warning_label_2.set_text("Warning: " + str(n))
		
func clear_warning(player_assign):
	if player_assign == player_1:
		warning_label_1.set_text("")
	else:
		warning_label_2.set_text("")
		
func get_player_sprite_pos(player_assign):
	if player_assign == player_1:
		return player_1_sprite.get_pos()
	else:
		return player_2_sprite.get_pos()

func play_animation(player_assign, animation):
	if player_assign == player_1:
		player_1_animation.play(animation)
	else:
		player_2_animation.play(animation)
	
func _process(delta):
	if chain_label_1_count >= chain_label_1_time:
		chain_label_1.set_text("")
	else:
		chain_label_1_count += 1
	if chain_label_2_count >= chain_label_2_time:
		chain_label_2.set_text("")
	else:
		chain_label_2_count += 1
	
	var player_1_upcoming_rubbish = playfield_1.upcoming_rubbish
	if player_1_upcoming_rubbish > 0:
		display_warning(player_1, player_1_upcoming_rubbish)
	else:
		clear_warning(player_1)

	var player_2_upcoming_rubbish = playfield_2.upcoming_rubbish
	if player_2_upcoming_rubbish > 0:
		display_warning(player_2, player_2_upcoming_rubbish)
	else:
		clear_warning(player_2)
		
func play_sound(sound):
	sample_player.play(sound)
		
func _ready():
	set_process(true)
	next_parent_1 = get_node("NextParent1")
	next_child_1 = get_node("NextChild1")
	next_parent_2 = get_node("NextParent2")
	next_child_2 = get_node("NextChild2")
	
	playfield_1 = get_node("Playfield1")
	playfield_2 = get_node("Playfield2")
	
	player_1_sprite = get_node("Player1")
	player_2_sprite = get_node("Player2")
	
	TYPE_NORMAL = playfield_1.TYPE_NORMAL
	TYPE_THROW = playfield_1.TYPE_THROW
	SPORT_SOCCER = playfield_1.SPORT_SOCCER
	SPORT_BASKET = playfield_1.SPORT_BASKET
	SPORT_BOWLING = playfield_1.SPORT_BOWLING
	SPORT_FOOTBALL = playfield_1.SPORT_FOOTBALL
	SPORT_TENNIS = playfield_1.SPORT_TENNIS
	SPORT_RUBBISH = playfield_1.SPORT_RUBBISH
	
	# Get textures
	soccer_ball_texture = playfield_1.soccer_ball_texture
	soccer_ball_throw_texture = playfield_1.soccer_ball_throw_texture
	basket_ball_texture = playfield_1.basket_ball_texture
	basket_ball_throw_texture = playfield_1.basket_ball_throw_texture
	bowling_ball_texture = playfield_1.bowling_ball_texture
	bowling_ball_throw_texture = playfield_1.bowling_ball_throw_texture
	football_ball_texture = playfield_1.football_ball_texture
	football_ball_throw_texture = playfield_1.football_ball_throw_texture
	tennis_ball_texture = playfield_1.tennis_ball_texture
	tennis_ball_throw_texture = playfield_1.tennis_ball_throw_texture
	rubbish_ball_texture = playfield_1.rubbish_ball_texture
	
	chain_label_1 = get_node("Chain1/Chain1")
	chain_label_2 = get_node("Chain2/Chain2")
	
	warning_label_1 = get_node("Warning1/Warning1")
	warning_label_2 = get_node("Warning2/Warning2")
	warning_label_1.set_text("")
	warning_label_2.set_text("")
	
	player_1_animation = player_1_sprite.get_node("AnimationPlayer")
	player_2_animation = player_2_sprite.get_node("AnimationPlayer")
	
	player_1_animation.play("Idle")
	player_2_animation.play("Idle")
	
	playfield_1.player_assign = player_1
	playfield_2.player_assign = player_2
	
	sample_player = get_node("Spatial/SamplePlayer")
	
	randomize()
	add_new_set_to_history()
	update_playfield_upcoming_balls_types(playfield_1)
	update_playfield_upcoming_balls_types(playfield_2)
	playfield_1.get_new_balls()
	playfield_2.get_new_balls()