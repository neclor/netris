extends Node2D

const pause_texture = preload("res://Assets/Sprites/Pause.png")
const start_texture = preload("res://Assets/Sprites/Start.png")

const sound_on_texture = preload("res://Assets/Sprites/SoundOn.png")
const sound_off_texture = preload("res://Assets/Sprites/SoundOff.png")

const field_height = 22
const field_width = 10

const top_border = -(field_height / 2 - 2) * Block.block_size
const bottom_border = (field_height / 2 - 1) * Block.block_size
const left_border = -(field_width / 2) * Block.block_size
const right_border =(field_width / 2 - 1) * Block.block_size

const initial_coordinates = Vector2(-Block.block_size, -(field_height / 2 - 1) * Block.block_size)

const figure_names = ["i", "o", "t", "j", "l", "s", "z", "g", "y"]

var figure_names_bag
var next_figure_name

var locked_blocks

var figure
var figure_ghost
var figure_next
var plus

var pause
var game_over

var score
var combo_counter
var number_lines

var player_name

#Basic functions

func interface_scaling():
	const block_size = Block.block_size
	const intrface_height = 28
	const intrface_width = 18

	var window_size = get_viewport().size
	var interface_scale = float(min(window_size.x / intrface_width, window_size.y / intrface_height)) / block_size

	var center = Vector2(window_size.x / 2, window_size.y / 2)

	$Field.position = Vector2(center.x, center.y + block_size * interface_scale)
	$Field.scale /= $Field.scale
	$Field.scale *= interface_scale

	$PauseField.position = Vector2(center.x, center.y + block_size * interface_scale)
	$PauseField.scale /= $PauseField.scale
	$PauseField.scale *= interface_scale
	
	$InfoField.position = Vector2(center.x, center.y + block_size * interface_scale)
	$InfoField.scale /= $InfoField.scale
	$InfoField.scale *= interface_scale

	$InfoField/Info.position = Vector2(-(field_width / 2 - 0.5) * block_size, -(field_height / 2 - 0.5) * block_size)
	$InfoField/Info.size = Vector2((field_width - 1) * block_size, (field_height - 1) * block_size)
	$InfoField/Info.add_theme_font_size_override("font_size", block_size / 2)

	$NextFigureField.position = Vector2(center.x, center.y - (field_height / 2 + 1) * block_size * interface_scale)
	$NextFigureField.scale /= $NextFigureField.scale
	$NextFigureField.scale *= interface_scale

	$GameOverField.position = Vector2(center.x, center.y - 5 * block_size * interface_scale)
	$GameOverField.scale /= $GameOverField.scale
	$GameOverField.scale *= interface_scale

	$GameOverField/GameOver.position = Vector2(-2 * block_size, -block_size)
	$GameOverField/GameOver.size = Vector2(4 * block_size, 2 * block_size)
	$GameOverField/GameOver.add_theme_font_size_override("font_size", block_size / 2)

	$GameOverField/RecordField.position = Vector2(0, 5.5 * block_size)
	$GameOverField/RecordField.scale /= $GameOverField/RecordField.scale

	$GameOverField/RecordField/AddRecord.position = Vector2(-2.5 * block_size, -1.5 * block_size)
	$GameOverField/RecordField/AddRecord.size = Vector2(5 * block_size, block_size)
	$GameOverField/RecordField/AddRecord.add_theme_font_size_override("font_size", block_size / 2)

	$GameOverField/RecordField/InputName.position = Vector2(-2.5 * block_size, -0.5 * block_size)
	$GameOverField/RecordField/InputName.size = Vector2(5 * block_size, block_size)
	$GameOverField/RecordField/InputName.add_theme_font_size_override("font_size", block_size / 2)

	$GameOverField/RecordField/AcceptName.position = Vector2(-block_size, 0.5 * block_size)
	$GameOverField/RecordField/AcceptName.size = Vector2(2 * block_size, block_size)
	$GameOverField/RecordField/AcceptName.add_theme_font_size_override("font_size", block_size / 2)

	$GameOverField/RecordField/ErrorField.position = Vector2(0, 0)
	$GameOverField/RecordField/ErrorField.scale /= $GameOverField/RecordField/ErrorField.scale
	
	$GameOverField/RecordField/ErrorField/ErrorPanel.position = Vector2(-3 * block_size, -1.5 * block_size)
	$GameOverField/RecordField/ErrorField/ErrorPanel.size = Vector2(6 * block_size, 3 * block_size)

	$GameOverField/RecordField/ErrorField/ErrorPanel/Error.position = Vector2(0, 0)
	$GameOverField/RecordField/ErrorField/ErrorPanel/Error.size = Vector2(6 * block_size, 1.5 * block_size)
	$GameOverField/RecordField/ErrorField/ErrorPanel/Error.add_theme_font_size_override("font_size", block_size / 2)

	$GameOverField/RecordField/ErrorField/ErrorPanel/EnterAnotherName.position = Vector2(0, 1.5 * block_size)
	$GameOverField/RecordField/ErrorField/ErrorPanel/EnterAnotherName.size = Vector2(4 * block_size, 1.5 * block_size)
	$GameOverField/RecordField/ErrorField/ErrorPanel/EnterAnotherName.add_theme_font_size_override("font_size", block_size / 2)

	$GameOverField/RecordField/ErrorField/ErrorPanel/SaveName.position = Vector2(4 * block_size, 1.5 * block_size)
	$GameOverField/RecordField/ErrorField/ErrorPanel/SaveName.size = Vector2(2 * block_size, 1.5 * block_size)
	$GameOverField/RecordField/ErrorField/ErrorPanel/SaveName.add_theme_font_size_override("font_size", block_size / 2)

	$Combo.position = Vector2(center.x + (field_width / 2 - 2) * block_size * interface_scale, center.y - (field_height / 2 + 2) * block_size * interface_scale)
	$Combo.size = Vector2(block_size * interface_scale, block_size * interface_scale)
	$Combo.add_theme_font_size_override("font_size", block_size * interface_scale / 2)

	$Score.position = Vector2(center.x + (field_width / 2 - 2) * block_size * interface_scale, center.y - (field_height / 2 + 1) * block_size * interface_scale)
	$Score.size = Vector2(block_size * interface_scale, block_size * interface_scale)
	$Score.add_theme_font_size_override("font_size", block_size * interface_scale / 2)

	$Speed.position = Vector2(center.x + (field_width / 2 + 0.5) * block_size * interface_scale, center.y - (field_height / 2 - 1) * block_size * interface_scale)
	$Speed.size = Vector2(block_size * interface_scale, block_size * interface_scale)
	$Speed.add_theme_font_size_override("font_size", block_size * interface_scale / 2)

	$Level.position = Vector2(center.x + (field_width / 2 + 0.5) * block_size * interface_scale, center.y - (field_height / 2 - 2) * block_size * interface_scale)
	$Level.size = Vector2(block_size * interface_scale, block_size * interface_scale)
	$Level.add_theme_font_size_override("font_size", block_size * interface_scale / 2)

	$NumberLines.position = Vector2(center.x + (field_width / 2 + 0.5) * block_size * interface_scale, center.y - (field_height / 2 - 3) * block_size * interface_scale)
	$NumberLines.size = Vector2(block_size * interface_scale, block_size * interface_scale)
	$NumberLines.add_theme_font_size_override("font_size", block_size * interface_scale / 2)

	$Neclor.position = Vector2(center.x - (field_width / 2 + 3) * block_size * interface_scale, center.y - (field_height / 2 + 2) * block_size * interface_scale)
	$Neclor.size = Vector2(2 * block_size * interface_scale, block_size * interface_scale)
	$Neclor.add_theme_font_size_override("font_size", block_size * interface_scale / 2)

	$PauseButton.position = Vector2(center.x - (field_width / 2 + 3) * block_size * interface_scale, center.y - (field_height / 2 - 1) * block_size * interface_scale)
	$PauseButton.size = Vector2(2 * block_size * interface_scale, 2 * block_size * interface_scale)

	$SoundButton.position = Vector2(center.x - (field_width / 2 + 3) * block_size * interface_scale, center.y - (field_height / 2 - 4) * block_size * interface_scale)
	$SoundButton.size = Vector2(2 * block_size * interface_scale, 2 * block_size * interface_scale)

	$InfoButton.position = Vector2(center.x - (field_width / 2 + 3) * block_size * interface_scale, center.y - (field_height / 2 - 7) * block_size * interface_scale)
	$InfoButton.size = Vector2(2 * block_size * interface_scale, 2 * block_size * interface_scale)

func _ready():
	player_name = ""

	init()
	interface_scaling()

func init():
	figure_names_bag = []
	locked_blocks = []

	pause = true
	game_over = true

	score = 0
	number_lines = 0
	combo_counter = 1

	$PauseField.visible = false
	$InfoField.visible = false
	$GameOverField.visible = false
	$GameOverField/RecordField.visible = false
	$GameOverField/RecordField/ErrorField.visible = false
	$GameOverField/RecordField/ErrorField/ErrorPanel/EnterAnotherName.visible = true

	update_level(0)
	update_score(0)
	update_speed()
	update_combo()

func start_game():
	for block in locked_blocks:
		block.queue_free()

	if plus != null:
		plus.remove()
		plus = null

	interface_scaling()

	init()

	choose_next_figure()
	creating_new_figure()

	pause = false
	game_over = false
	$GameTimer.start()

	$PauseButton.texture_normal = pause_texture
	$Music.volume_db = 0

func _on_game_timer_timeout():
	if !figure.check_move_down(locked_blocks):

		locked_blocks.append_array(figure.blocks)
		var check_line_fill = figure.check_line_fill(locked_blocks, field_width)

		locked_blocks = check_line_fill.locked_blocks

		if plus != null:
			if plus.check_collected(figure.blocks):
				update_score(2)
				plus.remove()
				plus = null

		if check_line_fill.number_filled_lines != 0:
			if plus != null:
				plus.remove()
				plus = null

			update_level(check_line_fill.number_filled_lines)
			update_score(check_line_fill.number_filled_lines)
			update_speed()

			combo_counter += 1

		else:
			combo_counter = 1

		update_combo()

		figure_next.remove()
		figure_ghost.remove()

		if !check_game_over():
			creating_new_figure()

func pause_game():
	$InfoField.visible = false

	if game_over:
		start_game()

	elif pause:
		pause = false
		$GameTimer.start()

		$PauseField.visible = false
		$PauseButton.texture_normal = pause_texture

	else:
		pause = true
		$GameTimer.stop()

		$PauseField.visible = true
		$PauseButton.texture_normal = start_texture

func pause_music():
	if $Music.playing:
		$Music.stop()

		$SoundButton.texture_normal = sound_on_texture

	else:
		$Music.play()

		$SoundButton.texture_normal = sound_off_texture

func info():
	if $InfoField.visible:
		$InfoField.visible = false

	else:
		$InfoField.visible = true

		if !game_over:
			pause = true
			$GameTimer.stop()

			$PauseField.visible = true
			$PauseButton.texture_normal = start_texture

#------ functions

func creating_new_figure():
	var choosed_figure = choose_next_figure()

	figure = Figure.new(choosed_figure, initial_coordinates, top_border, bottom_border, left_border, right_border)
	for block in figure.blocks:
		$Field.add_child(block)

	figure_next = Figure.new(next_figure_name, initial_coordinates, top_border, bottom_border, left_border, right_border)
	figure_next.change_into_next_figure()
	for block in figure_next.blocks:
		$NextFigureField.add_child(block)

	figure_ghost = Figure.new(choosed_figure, initial_coordinates, top_border, bottom_border, left_border, right_border)
	figure_ghost.change_into_ghost()
	figure_ghost.ghost_move_down(figure.coordinates, figure.blocks_coordinates, locked_blocks)
	for block in figure_ghost.blocks:
		$Field.add_child(block)

	if plus == null:
		plus = Plus.new()
		if plus.check_available_position(locked_blocks, top_border):
			$Field.add_child(plus.plus)
		else:
			plus = null

func choose_next_figure():
	if figure_names_bag == []:
		figure_names_bag = figure_names.duplicate()

	var new_figure_name_index = randi_range(0, len(figure_names_bag) - 1)
	var current_figure_name = next_figure_name

	next_figure_name = figure_names_bag[new_figure_name_index]
	figure_names_bag.remove_at(new_figure_name_index)

	return current_figure_name

func check_game_over():
	for block in locked_blocks:
		if block.position.y < top_border:
			pause = true
			game_over = true
			$GameTimer.stop()

			$GameOverField.visible = true
			$PauseButton.texture_normal = start_texture
			$Music.volume_db = -10

			add_record()

			return true
	return false

#Updating functions

func update_level(number_filled_lines):
	number_lines += number_filled_lines

	$NumberLines.text = "Lines: " + str(number_lines)

	var level = number_lines / 10
	$Level.text = "Level: " + str(level)

func update_score(number_filled_lines):
	var new_points = 0

	for i in number_filled_lines:
		new_points = (new_points * 2 + 100)
	new_points *= combo_counter
	score += new_points

	$Score.text = "Score: " + str(score)

func update_speed():
	var speed = 2 + number_lines / 10 * 0.5

	$GameTimer.wait_time = 1 / speed
	$Speed.text = "Speed: " + str(speed)

func update_combo():
	$Combo.text = "x" + str(combo_counter)

func add_record():
	if score != 0:
		if player_name == "":
			$GameOverField/RecordField.visible = true

		else:
			$GameOverField/RecordField/HTTPRequest.request_completed.connect(self.http_request_completed)
			$GameOverField/RecordField/HTTPRequest.request("https://neclor.ru/Records?name=%s&score=%d" % [player_name.uri_encode(), score], \
				[], HTTPClient.METHOD_POST, '{}')

func parse_http_headers(headers: Array) -> Dictionary:
	var result = {}
	for header in headers:
		var parts = header.split(":")
		if parts.size() >= 2:
			result[parts[0].strip_edges()] = parts[1]
	return result

func http_request_completed(result, response_code, headers, body):
	match response_code:
		200:
			start_game()

		304:
			$GameOverField/RecordField/ErrorField/ErrorPanel/Error.text = "This name is\nalready taken!"
			$GameOverField/RecordField/ErrorField.visible = true

		_:
			$GameOverField/RecordField/ErrorField/ErrorPanel/Error.text = parse_http_headers(headers)['x-message']
			$GameOverField/RecordField/ErrorField/ErrorPanel/EnterAnotherName.visible = false
			$GameOverField/RecordField/ErrorField.visible = true

#Сontrol functions

var used_button
var just_touch
var touch_position
var fall_check

func _on_pause_button_button_down():
	used_button = true
	pause_game()

func _on_sound_button_button_down():
	used_button = true
	pause_music()

func _on_info_button_button_down():
	used_button = true
	info()

func _on_accept_name_button_down():
	player_name = $GameOverField/RecordField/InputName.text
	add_record()

func _on_enter_another_name_button_down():
	$GameOverField/RecordField/ErrorField.visible = false

func _on_save_name_button_down():
	start_game()

func _input(event):
	if Input.is_action_just_pressed("Pause"):
			pause_game()

	if !pause:
		if Input.is_action_pressed("Down"):
			figure.check_move_down(locked_blocks)

		if Input.is_action_pressed("Right"):
			figure.check_move_right(locked_blocks)
			figure_ghost.ghost_move_down(figure.coordinates, figure.blocks_coordinates, locked_blocks)

		if Input.is_action_pressed("Left"):
			figure.check_move_left(locked_blocks)
			figure_ghost.ghost_move_down(figure.coordinates, figure.blocks_coordinates, locked_blocks)

		if Input.is_action_just_pressed("Rotation"):
			figure.check_move_rotation(locked_blocks, 1)
			figure_ghost.ghost_move_down(figure.coordinates, figure.blocks_coordinates, locked_blocks)

		if Input.is_action_just_pressed("AnotherRotation"):
			figure.check_move_rotation(locked_blocks, -1)
			figure_ghost.ghost_move_down(figure.coordinates, figure.blocks_coordinates, locked_blocks)

		if Input.is_action_just_pressed("Fall"):
			figure.move_fall(locked_blocks)
			_on_game_timer_timeout()

		if !used_button:
			if event is InputEventScreenTouch:
				if !event.is_pressed():
					if just_touch:
						figure.check_move_rotation(locked_blocks, 1)
						figure_ghost.ghost_move_down(figure.coordinates, figure.blocks_coordinates, locked_blocks)

				just_touch = true
				touch_position = event.position
				fall_check = true

			if event is InputEventScreenDrag:
				if event.velocity.y >= 2000:
					if fall_check:
						figure.move_fall(locked_blocks)
						_on_game_timer_timeout()
						fall_check = false

				elif event.position.y - touch_position.y >= Block.block_size:
					touch_position.y += Block.block_size
					figure.check_move_down(locked_blocks)

				if event.position.x - touch_position.x >= Block.block_size:
					touch_position.x += Block.block_size
					figure.check_move_right(locked_blocks)
					figure_ghost.ghost_move_down(figure.coordinates, figure.blocks_coordinates, locked_blocks)

				elif event.position.x - touch_position.x <= -Block.block_size:
					touch_position.x -= Block.block_size
					figure.check_move_left(locked_blocks)
					figure_ghost.ghost_move_down(figure.coordinates, figure.blocks_coordinates, locked_blocks)

				just_touch = false
		used_button = false
