extends Node2D

var parent_node2d

var tile_map
var tile_map_size
var tile_map_width
var tile_map_height
var tile_map_initial_y_pos

var game_field_rows = 12
var game_field_columns = 6

var game_tracker
var balls_remaining = 0
var balls_remaining_count = 0

enum {TYPE_NORMAL, TYPE_THROW}
enum {SPORT_SOCCER, SPORT_BASKET, SPORT_BOWLING, SPORT_FOOTBALL, SPORT_TENNIS, SPORT_RUBBISH}

var group_ball = "ball"
var group_rubbish = "rubbish"

var ball = preload("res://ball.tscn")

var soccer_ball_texture = preload("res://Sprites/ball_soccer.png")
var soccer_ball_throw_texture = preload("res://Sprites/throw_soccer.png")
var basket_ball_texture = preload("res://Sprites/ball_basket.png")
var basket_ball_throw_texture = preload("res://Sprites/throw_basket.png")
var bowling_ball_texture = preload("res://Sprites/ball_bowling.png")
var bowling_ball_throw_texture = preload("res://Sprites/throw_bowling.png")
var football_ball_texture = preload("res://Sprites/ball_football.png")
var football_ball_throw_texture = preload("res://Sprites/throw_football.png")
var tennis_ball_texture = preload("res://Sprites/ball_tennis.png")
var tennis_ball_throw_texture = preload("res://Sprites/throw_tennis.png")
var rubbish_ball_texture = preload("res://Sprites/duck.png")

#var debug_ball = [1,2,3,4,5,1]
#var debug_ball = [1,2,2,1]
#var debug_ball = [1,1]
var debug_ball = []

var upcoming_balls_types = []
var next_next_ball_parent = []
var next_next_ball_child = []

var score = 0
var attack = 0
var chain = 0

var score_per_attack = 4

var new_balls
var new_balls_drop_count = 0
var new_balls_ready_count = 0
var new_balls_inbetween_distance_px = 0

var debug_mode = true

enum {PARENT, CHILD}
enum {NA, ABOVE, RIGHT, BELOW, LEFT}

var single_player = false

var upcoming_rubbish = 0
var checked_rubbish = true
var previous_rubbish_drop = 0

var player_assign

var anim_cheer
var anim_hurt
var anim_idle
var anim_kick

var throw_collision_mask = 4
var throw_layer_mask = 4

var sound_rubbish
var sound_throw

func y_pos_to_row(y_pos):
	return int(y_pos / tile_map_height)
	
func x_pos_to_column(x_pos):
	return int(x_pos / tile_map_width)

func reset_balls_remaining():
	balls_remaining = 0
	balls_remaining_count = 0

func get_new_ball(first):
	new_balls += 1
	randomize()
	var rand_sport_type = randi()%5+1 # int from 1 to 5
	var rand_throw_type = randi()%100+1 # int from 1 to 100
#	var rand_sport_type = int(rand_range(1, 6))
#	var rand_throw_type = int(rand_range(1, 101))
	var new_ball = ball.instance()
	var ball_initial_column = 3 # columns start from 0
	var ball_initial_x_pos = ball_initial_column * tile_map_width + tile_map_initial_y_pos
	var ball_initial_y_pos
	var ball_texture
	
	if upcoming_balls_types.size() == 0 and not single_player:
		parent_node2d.update_playfield_upcoming_balls_types(self)
	
	# Debug choose specific balls
	if debug_ball.size() > 0:
		var next_ball = debug_ball[0]
		debug_ball.pop_front()
		if next_ball == 1:
			new_ball.sport = SPORT_SOCCER
		elif next_ball == 2:
			new_ball.sport = SPORT_BASKET
		elif next_ball == 3:
			new_ball.sport = SPORT_BOWLING
		elif next_ball == 4:
			new_ball.sport = SPORT_FOOTBALL
		elif next_ball == 5:
			new_ball.sport = SPORT_TENNIS
		new_ball.type = TYPE_THROW
		debug_ball.append(next_ball)
	elif upcoming_balls_types.size() > 0:
		var next_ball_type = upcoming_balls_types[0]
		upcoming_balls_types.pop_front()
		var next_ball = next_ball_type[0]
		var next_type = next_ball_type[1]
		var next_next_ball_type = upcoming_balls_types[1]
		var next_next_ball = next_next_ball_type[0]
		var next_next_type = next_next_ball_type[1]
		
		if next_next_ball == 1:
			next_next_ball = SPORT_SOCCER
		elif next_next_ball == 2:
			next_next_ball = SPORT_BASKET
		elif next_next_ball == 3:
			next_next_ball = SPORT_BOWLING
		elif next_next_ball == 4:
			next_next_ball = SPORT_FOOTBALL
		elif next_next_ball == 5:
			next_next_ball = SPORT_TENNIS

		if next_next_type <= 40:
			next_next_type = TYPE_THROW
		else:
			next_next_type = TYPE_NORMAL
		
		if first:
			next_next_ball_parent = [] + [next_next_ball, next_next_type]
		else:
			next_next_ball_child = [] + [next_next_ball, next_next_type]
#		
		if next_ball == 1:
			new_ball.sport = SPORT_SOCCER
		elif next_ball == 2:
			new_ball.sport = SPORT_BASKET
		elif next_ball == 3:
			new_ball.sport = SPORT_BOWLING
		elif next_ball == 4:
			new_ball.sport = SPORT_FOOTBALL
		elif next_ball == 5:
			new_ball.sport = SPORT_TENNIS

		if next_type <= 40:
			new_ball.type = TYPE_THROW
		else:
			new_ball.type = TYPE_NORMAL

	else:
		if rand_sport_type == 1:
			new_ball.sport = SPORT_SOCCER
		elif rand_sport_type == 2:
			new_ball.sport = SPORT_BASKET
		elif rand_sport_type == 3:
			new_ball.sport = SPORT_BOWLING
		elif rand_sport_type == 4:
			new_ball.sport = SPORT_FOOTBALL
		elif rand_sport_type == 5:
			new_ball.sport = SPORT_TENNIS
		
		if rand_throw_type <= 40:
			new_ball.type = TYPE_THROW
		else:
			new_ball.type = TYPE_NORMAL
			
	if new_ball.sport == SPORT_SOCCER and new_ball.type == TYPE_NORMAL:
		ball_texture = soccer_ball_texture
	elif new_ball.sport == SPORT_SOCCER and new_ball.type == TYPE_THROW:
		ball_texture = soccer_ball_throw_texture
	elif new_ball.sport == SPORT_BASKET and new_ball.type == TYPE_NORMAL:
		ball_texture = basket_ball_texture
	elif new_ball.sport == SPORT_BASKET and new_ball.type == TYPE_THROW:
		ball_texture = basket_ball_throw_texture
	elif new_ball.sport == SPORT_BOWLING and new_ball.type == TYPE_NORMAL:
		ball_texture = bowling_ball_texture
	elif new_ball.sport == SPORT_BOWLING and new_ball.type == TYPE_THROW:
		ball_texture = bowling_ball_throw_texture
	elif new_ball.sport == SPORT_FOOTBALL and new_ball.type == TYPE_NORMAL:
		ball_texture = football_ball_texture
	elif new_ball.sport == SPORT_FOOTBALL and new_ball.type == TYPE_THROW:
		ball_texture = football_ball_throw_texture
	elif new_ball.sport == SPORT_TENNIS and new_ball.type == TYPE_NORMAL:
		ball_texture = tennis_ball_texture
	elif new_ball.sport == SPORT_TENNIS and new_ball.type == TYPE_THROW:
		ball_texture = tennis_ball_throw_texture

	new_ball.get_node("Sprite").set_texture(ball_texture)
	if first:
		ball_initial_y_pos = -tile_map_initial_y_pos
		new_ball.set_pos(Vector2(ball_initial_x_pos, ball_initial_y_pos))
		new_ball.status = PARENT
		new_ball.direction = NA
	else:
		ball_initial_y_pos = -tile_map_initial_y_pos - tile_map_height
		new_ball.set_pos(Vector2(ball_initial_x_pos, ball_initial_y_pos))
		new_ball.status = CHILD
		new_ball.direction = ABOVE
	add_child(new_ball)
	return new_ball

func get_new_balls():
	new_balls = 0
	var first_ball = get_new_ball(true)
	var second_ball = get_new_ball(false)
	first_ball.other_ball = second_ball
	second_ball.other_ball = first_ball
	parent_node2d.update_next_next_balls(player_assign)
	parent_node2d.play_animation(player_assign, anim_kick)
	
func calculate_attack_after_rubbish():
	attack = chain * score / score_per_attack
	var initial_rubbish = upcoming_rubbish
	upcoming_rubbish -= attack
	attack -= initial_rubbish
	if upcoming_rubbish < 0:
		upcoming_rubbish = 0
	if attack < 0:
		attack = 0
	if attack > 0:
		parent_node2d.send_attack_to_other_player(player_assign, attack)
	if chain > 1:
		parent_node2d.display_chain(player_assign, chain)
	score = 0
	chain = 0
	attack = 0
	check_for_rubbish()

func check_balls_to_remove():
	var balls_to_remove = {}
	var i = 0
	for row in game_tracker:
		var j = 0
		for ball in row:
			if ball_exists(ball):
				if ball.type == TYPE_THROW:
					if nearby_same_sport_balls(ball, i, j):
						mark_same_sport_balls_to_remove(balls_to_remove, ball, i, j)
			j += 1
		i += 1
	var no_balls_to_remove = balls_to_remove.keys().size()
	score += no_balls_to_remove
	if no_balls_to_remove == 0:
		var game_over = check_for_game_over()
		if not game_over:
			calculate_attack_after_rubbish()
		else:
			global.loser = player_assign
			get_tree().change_scene("res://win.tscn")
	else:
		chain += 1
	remove_same_sport_balls(balls_to_remove)
	# Get remaining number of balls
	reset_balls_remaining()
	balls_remaining = get_ball_count()
	if balls_remaining == 0:
		calculate_attack_after_rubbish()
	new_balls_drop_count = 0
	if checked_rubbish:
		balls_remaining = previous_rubbish_drop

# returns: Boolean
func nearby_same_sport_balls(throw_ball, row_index, column_index):
	# Check above
	if row_index != 0:
		var above_ball = game_tracker[row_index - 1][column_index]
		if above_ball:
			if same_sport(throw_ball, above_ball):
				return true
	# Check below
	if row_index != game_field_rows - 1:
		var below_ball = game_tracker[row_index + 1][column_index]
		if below_ball:
			if same_sport(throw_ball, below_ball):
				return true
	# Check left
	if column_index != 0:
		var left_ball = game_tracker[row_index][column_index - 1]
		if left_ball:
			if same_sport(throw_ball, left_ball):
				return true
	# Check right
	if column_index != game_field_columns - 1:
		var right_ball = game_tracker[row_index][column_index + 1]
		if right_ball:
			if same_sport(throw_ball, right_ball):
				return true
			
	return false
	
func same_sport(ball_1, ball_2):
	if ball_exists(ball_1) and ball_exists(ball_2):
		return ball_1.sport == ball_2.sport

func mark_same_sport_balls_to_remove(balls_to_remove, ball, row_index, column_index):
	balls_to_remove[Vector2(row_index, column_index)] = ball
	# Check above

	if row_index != 0:
		var above_ball_row_index = row_index - 1
		var above_ball = game_tracker[above_ball_row_index][column_index]
		if above_ball:
			var are_same_sport = same_sport(ball, above_ball)
			if are_same_sport or above_ball.sport == SPORT_RUBBISH:
				var above_ball_key = Vector2(above_ball_row_index, column_index)
				if not balls_to_remove.has(above_ball_key):
					balls_to_remove[above_ball_key] = above_ball
					if are_same_sport:
						mark_same_sport_balls_to_remove(balls_to_remove, above_ball, above_ball_row_index, column_index)
	# Check below
	if row_index != game_field_rows - 1:
		var below_ball_row_index = row_index + 1
		var below_ball = game_tracker[below_ball_row_index][column_index]
		if below_ball:
			var are_same_sport = same_sport(ball, below_ball)
			if are_same_sport or below_ball.sport == SPORT_RUBBISH:
				var below_ball_key = Vector2(below_ball_row_index, column_index)
				if not balls_to_remove.has(below_ball_key):
					balls_to_remove[below_ball_key] = below_ball
					if are_same_sport:
						mark_same_sport_balls_to_remove(balls_to_remove, below_ball, below_ball_row_index, column_index)
	# Check left
	if column_index != 0:
		var left_ball_column_index = column_index - 1
		var left_ball = game_tracker[row_index][left_ball_column_index]
		if left_ball:
			var are_same_sport = same_sport(ball, left_ball)
			if are_same_sport or left_ball.sport == SPORT_RUBBISH:
				var left_ball_key = Vector2(row_index, left_ball_column_index)
				if not balls_to_remove.has(left_ball_key):
					balls_to_remove[left_ball_key] = left_ball
					if are_same_sport:
						mark_same_sport_balls_to_remove(balls_to_remove, left_ball, row_index, left_ball_column_index)
	# Check right
	if column_index != game_field_columns - 1:
		var right_ball_column_index = column_index + 1
		var right_ball = game_tracker[row_index][right_ball_column_index]
		if right_ball:
			var are_same_sport = same_sport(ball, right_ball)
			if are_same_sport or right_ball.sport == SPORT_RUBBISH:
				var right_ball_key = Vector2(row_index, right_ball_column_index)
				if not balls_to_remove.has(right_ball_key):
					balls_to_remove[right_ball_key] = right_ball
					if are_same_sport:
						mark_same_sport_balls_to_remove(balls_to_remove, right_ball, row_index, right_ball_column_index)
					
# param balls_to_remove: Dictionary[Vector2(row, column)] = KinematicBody2D Ball
func remove_same_sport_balls(balls_to_remove):
	var drop_remaining_balls = balls_to_remove.size() > 0
	for indexes in balls_to_remove:
		var row = indexes[0]
		var column = indexes[1]
		var ball = game_tracker[row][column]
		var player_sprite_pos = parent_node2d.get_player_sprite_pos(player_assign)
		if ball.is_in_group(group_ball):
			ball.remove_from_group(group_ball)
		if ball.is_in_group(group_rubbish):
			ball.remove_from_group(group_rubbish)
		ball.set_collision_mask(throw_collision_mask)
		ball.set_layer_mask(throw_layer_mask)
		ball.enable_velocity = false
		ball.tween.interpolate_property(ball, "transform/pos", ball.get_pos(), player_sprite_pos - get_pos(), ball.tween_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
		ball.tween.interpolate_callback(ball, ball.tween_duration, 'queue_free')
		ball.tween.start()
		game_tracker[row][column] = null
	balls_to_remove = {}
	# Re-enable remaining balls to fall into place
	var count = 0
	if drop_remaining_balls:
		parent_node2d.play_animation(player_assign, anim_cheer)
		parent_node2d.play_sound(sound_throw)
		for row in game_tracker:
			for ball in row:
				if ball_exists(ball):
					ball.re_enabled = true
					ball.enable = true

func ball_exists(ball):
	if ball:
		var ball_ref = weakref(ball).get_ref()
		if ball_ref:
			return true
		else:
			return false
	else:
		return false

func check_for_game_over():
	var child_nodes = get_children()
	for node in child_nodes:
		if node.is_in_group(group_ball):
			# Check if out of bounds
			var y_pos = node.get_pos()[1]
			if y_pos < 0:
				return true
	return false
	
func update_game_tracker():
	initialise_empty_game_tracker()
	var child_nodes = get_children()
	for node in child_nodes:
		if node.is_in_group(group_ball) or node.is_in_group(group_rubbish):
			var pos = node.get_pos()
			var row = y_pos_to_row(pos[1])
			var column = x_pos_to_column(pos[0])
			game_tracker[row][column] = node
			# Update position as a safe guard
#			var new_x_pos = column * tile_map_width + tile_map_initial_y_pos
#			var new_y_pos = row * tile_map_height + tile_map_initial_y_pos
#			var new_pos = Vector2(new_x_pos, new_y_pos)
#			node.set_pos(new_pos)
	
func initialise_empty_game_tracker():
	game_tracker = []
	for x in range(game_field_rows):
		game_tracker.append([])
		for y in range(game_field_columns):
			game_tracker[x].append(null)

func get_ball_count():
	var count = 0
	for row in game_tracker:
		for item in row:
			if item:
				count += 1
	return count
	
func shuffle_array(array):
	var copy_array = [] + array
	var new_array = []
	randomize()
	for _ in range(copy_array.size()):
		var value = copy_array[randi()%copy_array.size()]
		new_array.append(value)
		copy_array.erase(value)
	return new_array
	
func add_rubbish(n):
	upcoming_rubbish += n
	
func check_for_rubbish():
	if upcoming_rubbish > 0:
		rubbish_drop(upcoming_rubbish)
		upcoming_rubbish = 0
	else:
		get_new_balls()
	checked_rubbish = true
	
func rubbish_drop(n):
	# Build array of sequential index numbers
	previous_rubbish_drop = n
	parent_node2d.play_animation(player_assign, anim_hurt)
	parent_node2d.play_sound(sound_rubbish)
	var row_count = 0
	while n > 0:
		var rubbish_order = []
		var row_drop_count = 0
		for num in range(game_field_columns):
			rubbish_order.append(num)
			row_drop_count += 1
		rubbish_order = shuffle_array(rubbish_order)
		# Drop rubbish
		var count = 0
		var rubbish_ball
		var ball_initial_x_pos
		var ball_initial_y_pos
		var rubbish_ball_sprite_node
		for i in rubbish_order:
			if i < n:
				rubbish_ball = ball.instance()
				rubbish_ball.type = TYPE_NORMAL
				rubbish_ball.sport = SPORT_RUBBISH
				ball_initial_x_pos = count * tile_map_width + tile_map_initial_y_pos
				ball_initial_y_pos = tile_map_initial_y_pos - row_count * tile_map_height
				rubbish_ball_sprite_node = rubbish_ball.get_node("Sprite")
				rubbish_ball_sprite_node.set_texture(rubbish_ball_texture)
				rubbish_ball.set_pos(Vector2(ball_initial_x_pos, ball_initial_y_pos))
				rubbish_ball.remove_from_group(group_ball)
				rubbish_ball.add_to_group(group_rubbish)
				add_child(rubbish_ball)
			count += 1
		row_count += 1
		n -= row_drop_count
		
func _input(event):
	if event.is_action_pressed(player_assign + "_debug_rubbish"):
		add_rubbish(1)
		
func _ready():
	set_process_input(true)
	parent_node2d = get_parent()
	
	tile_map = get_node("TileMap")
	tile_map_size = tile_map.get_cell_size()
	tile_map_width = tile_map_size[0] * tile_map.get_scale()[0]
	tile_map_height = tile_map_size[1] * tile_map.get_scale()[1]
	tile_map_initial_y_pos = tile_map_width / 2
	
	anim_cheer = parent_node2d.anim_cheer
	anim_hurt = parent_node2d.anim_hurt
	anim_idle = parent_node2d.anim_idle
	anim_kick = parent_node2d.anim_kick
	
	sound_rubbish = parent_node2d.sound_rubbish
	sound_throw = parent_node2d.sound_throw
	
	initialise_empty_game_tracker()
	if single_player:
		get_new_balls()