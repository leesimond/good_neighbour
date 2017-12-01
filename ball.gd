extends KinematicBody2D

var tile_map_width
var tile_map_height
var tile_map_initial_y_pos

var parent_node2d
var game_field_rows
var game_field_columns

var game_tracker

var default_collision_mask = 1
var new_drop_collision_mask = 2


var type = "Not set"
var sport = "Not set"

var enable_velocity = true
var tween
var tween_duration = 1.0

var SPORT_RUBBISH

const NORMAL_GRAVITY = 80
const HEAVY_GRAVITY = 1580
const VERY_HEAVY_GRAVITY = 5000
var gravity = NORMAL_GRAVITY

var velocity = Vector2()

var moved = false
var moved_timer = 0
var moved_timer_reset = 8

var enable = true
var re_enabled = false

var same_pos_buffer = 10
var same_pos_count = 0

var removed_re_enabled_ball = false
var move_result = Vector2()

var status
var PARENT
var CHILD

var direction
var NA
var ABOVE
var RIGHT
var BELOW
var LEFT

var collision_buffer = 10
var collision_count = 0

var other_ball
var other_ball_collided = false

var player_assign

var game_node2d

var sound_anti_clockwise
var sound_clockwise
var sound_drop
var sound_rubbish
var sound_throw

func enable():
	enable = true

func reset_moved():
	moved_timer = 0
	moved = false

func y_pos_to_row(y_pos):
	return int(y_pos / tile_map_height)
	
func x_pos_to_column(x_pos):
	return int(x_pos / tile_map_width)

func add_ball_to_game_tracker(game_tracker, pos, ball, tile_map_width, tile_map_height, tile_map_initial_y_pos):
	var row = y_pos_to_row(pos[1])
	var column = x_pos_to_column(pos[0])
	game_tracker[row][column] = ball

func remove_ball_from_game_tracker(game_tracker, pos, ball, tile_map_width, tile_map_height, tile_map_initial_y_pos):
	var row = y_pos_to_row(pos[1])
	var column = x_pos_to_column(pos[0])
	game_tracker[row][column] = null

func ball_exists(row, column):
	if row < 0 or row > game_field_rows - 1 or column < 0 or column > game_field_columns - 1:
		return false
	return game_tracker[row][column]
	
func rotate_clockwise():
	if status == CHILD:
		var current_pos = get_pos()
		var x_pos = current_pos[0]
		var y_pos = current_pos[1]
		var new_x_pos
		var new_y_pos
		if direction == ABOVE:
			var row = y_pos_to_row(y_pos)
			var column = x_pos_to_column(x_pos)
			if not column + 1 > game_field_columns - 1 and not ball_exists(row + 1, column + 1) and not ball_exists(row - 1, column + 1):
				new_x_pos = x_pos + tile_map_width
				new_y_pos = y_pos + tile_map_height
				set_pos(Vector2(new_x_pos, new_y_pos))
				direction = RIGHT
		elif direction == RIGHT:
			new_x_pos = x_pos - tile_map_width
			new_y_pos = y_pos + tile_map_height
			set_pos(Vector2(new_x_pos, new_y_pos))
			direction = BELOW
		elif direction == BELOW:
			var row = y_pos_to_row(y_pos)
			var column = x_pos_to_column(x_pos)
			if not column - 1 < 0 and not ball_exists(row, column - 1):
				new_x_pos = x_pos - tile_map_width
				new_y_pos = y_pos - tile_map_height
				set_pos(Vector2(new_x_pos, new_y_pos))
				direction = LEFT
		elif direction == LEFT:
			new_x_pos = x_pos + tile_map_width
			new_y_pos = y_pos - tile_map_height
			set_pos(Vector2(new_x_pos, new_y_pos))
			direction = ABOVE
			
func rotate_anti_clockwise():
	if status == CHILD:
		var current_pos = get_pos()
		var x_pos = current_pos[0]
		var y_pos = current_pos[1]
		var new_x_pos
		var new_y_pos
		if direction == ABOVE:
			var row = y_pos_to_row(y_pos)
			var column = x_pos_to_column(x_pos)
			if not column - 1 < 0 and not ball_exists(row + 1, column - 1) and not ball_exists(row - 1, column - 1):
				new_x_pos = x_pos - tile_map_width
				new_y_pos = y_pos + tile_map_height
				set_pos(Vector2(new_x_pos, new_y_pos))
				direction = LEFT
		elif direction == LEFT:
			new_x_pos = x_pos + tile_map_width
			new_y_pos = y_pos + tile_map_height
			set_pos(Vector2(new_x_pos, new_y_pos))
			direction = BELOW
		elif direction == BELOW:
			var row = y_pos_to_row(y_pos)
			var column = x_pos_to_column(x_pos)
			if not column + 1 > game_field_columns - 1 and not ball_exists(row, column + 1):
				new_x_pos = x_pos + tile_map_width
				new_y_pos = y_pos - tile_map_height
				set_pos(Vector2(new_x_pos, new_y_pos))
				direction = RIGHT
		elif direction == RIGHT:
			new_x_pos = x_pos - tile_map_width
			new_y_pos = y_pos - tile_map_height
			set_pos(Vector2(new_x_pos, new_y_pos))
			direction = ABOVE
			
func can_move_left(at_left_most_column, other_ball_at_left_most_column, at_second_left_most_column):
	if status == PARENT:
		if other_ball.direction == LEFT and other_ball_at_left_most_column:
			return false
	elif status == CHILD:
		if direction == RIGHT and at_second_left_most_column:
			return false
	if at_left_most_column:
		return false
	return true
	
func can_move_right(at_right_most_column, other_ball_at_right_most_column, at_second_right_most_column):
	if status == PARENT:
		if other_ball.direction == RIGHT and other_ball_at_right_most_column:
			return false
	elif status == CHILD:
		if direction == LEFT and at_second_right_most_column:
			return false
	if at_right_most_column:
		return false
	return true

func _fixed_process(delta):
	if enable_velocity:
		velocity.y += delta * gravity
		if enable:
			if not re_enabled and not sport == SPORT_RUBBISH:
				var current_pos = get_pos()
				var x_pos = current_pos[0]
				var y_pos = current_pos[1]
				var other_ball_current_pos = other_ball.get_pos()
				var other_ball_x_pos = other_ball_current_pos[0]
				var other_ball_y_pos = other_ball_current_pos[1]
				var at_left_most_column = x_pos == tile_map_initial_y_pos
				var at_right_most_column = x_pos == tile_map_width * game_field_columns - tile_map_initial_y_pos
				var at_second_left_most_column = x_pos == tile_map_initial_y_pos + tile_map_width
				var at_second_right_most_column = x_pos == tile_map_width * game_field_columns - tile_map_initial_y_pos - tile_map_width
				var other_ball_at_left_most_column = other_ball_x_pos == tile_map_initial_y_pos
				var other_ball_at_right_most_column = other_ball_x_pos == tile_map_width * game_field_columns - tile_map_initial_y_pos
				if not other_ball_collided:
					if Input.is_action_pressed(player_assign + "_up"):
						gravity = VERY_HEAVY_GRAVITY
					elif Input.is_action_pressed(player_assign + "_down"):
						gravity = HEAVY_GRAVITY
					elif Input.is_action_pressed(player_assign + "_left") and can_move_left(at_left_most_column, other_ball_at_left_most_column, at_second_left_most_column):
						var row = y_pos_to_row(y_pos)
						var column = x_pos_to_column(x_pos - tile_map_width)
						var other_ball_row = y_pos_to_row(other_ball_y_pos)
						var other_ball_column = x_pos_to_column(other_ball_x_pos - tile_map_width)
						if not ball_exists(row, column) and not ball_exists(other_ball_row, other_ball_column):
							if not moved:
								moved = true
								set_pos(Vector2(x_pos - tile_map_width, y_pos))
					elif Input.is_action_pressed(player_assign + "_right") and can_move_right(at_right_most_column, other_ball_at_right_most_column, at_second_right_most_column):
						var row = y_pos_to_row(y_pos)
						var column = x_pos_to_column(x_pos + tile_map_width)
						var other_ball_row = y_pos_to_row(other_ball_y_pos)
						var other_ball_column = x_pos_to_column(other_ball_x_pos + tile_map_width)
						if not ball_exists(row, column) and not ball_exists(other_ball_row, other_ball_column):
							if not moved:
								moved = true
								set_pos(Vector2(x_pos + tile_map_width, y_pos))
						pass
					if moved:
						moved_timer += 1
						if moved_timer == moved_timer_reset:
							reset_moved()
				if is_colliding():
					game_node2d.play_sound(sound_drop)
					other_ball.other_ball_collided = true
					other_ball.set_collision_mask(default_collision_mask)
					set_collision_mask(default_collision_mask)
					gravity = HEAVY_GRAVITY
					other_ball.gravity = HEAVY_GRAVITY
					collision_count = 0
					velocity = Vector2()
					enable = false
					parent_node2d.new_balls_drop_count += 1
					if parent_node2d.new_balls_drop_count == parent_node2d.new_balls:
						parent_node2d.checked_rubbish = false
						parent_node2d.update_game_tracker()
						parent_node2d.check_balls_to_remove()
			else:
				var y_move_result = move_result[1]
				if y_move_result > 0:
					if sport == SPORT_RUBBISH:
						set_collision_mask(default_collision_mask)
					same_pos_count += 1
				else:
					same_pos_count = 0
				if same_pos_count > same_pos_buffer:
					game_node2d.play_sound(sound_drop)
					enable = false
					removed_re_enabled_ball = false
					parent_node2d.balls_remaining_count += 1
					same_pos_count = 0
					if parent_node2d.balls_remaining_count == parent_node2d.balls_remaining:
						parent_node2d.update_game_tracker()
						parent_node2d.check_balls_to_remove()
						
		var motion = velocity * delta
		move_result = move(motion)
		
		
func _input(event):
	if enable and not re_enabled:
		if sport != SPORT_RUBBISH:
			if event.is_action_released(player_assign + "_left"):
				reset_moved()
			if event.is_action_released(player_assign + "_right"):
				reset_moved()
			if event.is_action_released(player_assign + "_down"):
				gravity = NORMAL_GRAVITY
				velocity = Vector2()
		if status == CHILD:
			if event.is_action_pressed(player_assign + "_rotate_clockwise"):
				rotate_clockwise()
				game_node2d.play_sound(sound_clockwise)
			elif event.is_action_pressed(player_assign + "_rotate_anti_clockwise"):
				rotate_anti_clockwise()
				game_node2d.play_sound(sound_anti_clockwise)
	
func _ready():
	parent_node2d = get_parent()
	game_node2d = parent_node2d.get_parent()
	tween = get_node("Tween")
	player_assign = parent_node2d.player_assign
	game_field_rows = parent_node2d.game_field_rows
	game_field_columns = parent_node2d.game_field_columns
	tile_map_width = parent_node2d.tile_map_width
	tile_map_height = parent_node2d.tile_map_height
	tile_map_initial_y_pos = parent_node2d.tile_map_initial_y_pos
	game_tracker = parent_node2d.game_tracker
	SPORT_RUBBISH = parent_node2d.SPORT_RUBBISH
	PARENT = parent_node2d.PARENT
	CHILD = parent_node2d.CHILD
	ABOVE = parent_node2d.ABOVE
	RIGHT = parent_node2d.RIGHT
	BELOW = parent_node2d.BELOW
	LEFT = parent_node2d.LEFT
	
	sound_anti_clockwise = game_node2d.sound_anti_clockwise
	sound_clockwise = game_node2d.sound_clockwise
	sound_drop = game_node2d.sound_drop
	
	set_fixed_process(true)
	set_process_input(true)
	
	
	set_collision_mask(new_drop_collision_mask)
	
	if sport == SPORT_RUBBISH:
		gravity = HEAVY_GRAVITY
	else:
		parent_node2d.new_balls_ready_count += 1