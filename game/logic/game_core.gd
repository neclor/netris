class_name Game extends RefCounted


signal score_changed(value: int)
signal combo_counter_changed(value: int)
signal speed_changed(value: float)
signal destroyed_line_count_changed(value: int)


signal figure_changed
signal next_figure_changed
signal hold_figure_changed
signal bonus_figure_changed


signal bonus_figure_gained(value: int)


var score: int = 0:
	set = set_score
var combo_counter: int = 1:
	set = set_combo_counter
var speed: float = 2:
	set = set_speed
var destroyed_line_count: int = 0:
	set = set_destroyed_line_count


var current_figure: Figure
var hold_figure: Figure
var bonus_figure_place: Figure

var field: Field = Field.new()
var figure_pool: FigurePool = FigurePool.new()

var game_over: bool

var _swap_allowed: bool


func _init() -> void:
	randomize()
	init()


func init() -> void:
	score = 0
	destroyed_line_count = 0
	combo_counter = 1
	speed = 2

	field.clear()
	figure_pool.refill()

	current_figure = null
	hold_figure = null
	bonus_figure_place = null

	game_over = false

	_swap_allowed = true


func start() -> void:
	_spawn_next_figure()
	_spawn_bonus_figure_place()


func set_score(value: int) -> void:
	if score == value: return
	score = value
	score_changed.emit(value)


func set_combo_counter(value: int) -> void:
	if combo_counter == value: return
	combo_counter = value
	combo_counter_changed.emit(value)


func set_speed(value: float) -> void:
	if speed == value: return
	speed = value
	speed_changed.emit(value)


func set_destroyed_line_count(value: int) -> void:
	if destroyed_line_count == value: return
	destroyed_line_count = value
	destroyed_line_count_changed.emit(value)


func step() -> void:
	if game_over: return
	if try_move_figure(Figure.Direction.DOWN): return
	_place_current_figure()
	_update_speed()
	_swap_allowed = true


func try_move_figure(direction: Figure.Direction) -> bool: 
	if _try_move_figure(current_figure, direction):
		figure_changed.emit()
		return true
	return false


func try_rotate_figure(rotation: Figure.Rotation) -> bool: 
	if _try_rotate_figure(current_figure, rotation):
		figure_changed.emit()
		return true
	return false


func drop_figure() -> void: 
	_drop_figure(current_figure)
	_place_current_figure()


func try_swap_figure() -> bool:
	if not _swap_allowed: return false
	if (hold_figure == null):
		hold_figure = current_figure
		_swap_allowed = false
		_spawn_next_figure()
		hold_figure_changed.emit()
		return true
	hold_figure.position = current_figure.position
	if not field.check_figure_collides(hold_figure) or _try_rotate_figure(hold_figure):
		var temp: Figure = current_figure
		current_figure = hold_figure
		hold_figure = temp
		_swap_allowed = false
		figure_changed.emit()
		hold_figure_changed.emit()
		return true
	return false


func get_ghost_figure() -> Figure:
	var ghost_figure: Figure = current_figure.duplicate()
	_drop_figure(ghost_figure)
	return ghost_figure


func _try_move_figure(figure: Figure, direction: Figure.Direction = Figure.Direction.DOWN) -> bool:
	var new_figure: Figure = figure.duplicate()
	new_figure.move(direction)
	if field.check_figure_collides(new_figure): return false
	figure.move(direction)
	return true


func _try_rotate_figure(figure: Figure, rotation: Figure.Rotation = Figure.Rotation.CLOCKWISE) -> bool:
	var new_figure: Figure = figure.duplicate()
	var initial_position: Vector2i = figure.position
	var initial_direction: Figure.Direction = figure.direction

	var rotation_list: Array[Figure.Rotation] = []
	match rotation:
		Figure.Rotation.CLOCKWISE: rotation_list = [Figure.Rotation.CLOCKWISE, Figure.Rotation.ROTATE180, Figure.Rotation.COUNTERCLOCKWISE]
		Figure.Rotation.COUNTERCLOCKWISE: rotation_list = [Figure.Rotation.COUNTERCLOCKWISE, Figure.Rotation.ROTATE180, Figure.Rotation.CLOCKWISE]
		Figure.Rotation.ROTATE180: rotation_list = [Figure.Rotation.ROTATE180, Figure.Rotation.CLOCKWISE, Figure.Rotation.COUNTERCLOCKWISE] 
		_: rotation_list = []

	var offset_list: Array[Vector2i] = [Vector2i.ZERO, Vector2i.RIGHT, Vector2i.LEFT]
	if figure.type == Figure.Type.I:
		offset_list += [Vector2i.RIGHT * 2, Vector2i.LEFT * 2]

	for r in rotation_list:
		new_figure.direction = initial_direction
		new_figure.rotate(r)
		for offset in offset_list:
			new_figure.position = initial_position + offset
			if field.check_figure_collides(new_figure): continue
			figure.position = new_figure.position
			figure.direction = new_figure.direction
			return true
	return false


func _drop_figure(figure: Figure) -> void: 
	while _try_move_figure(figure): pass


func _place_current_figure() -> void:
	field.place_figure(current_figure)
	_check_bonus_figure_place()
	var line_count: int = field.destroy_lines()
	_update_score(line_count)
	if line_count != 0:
		combo_counter += 1
		_spawn_bonus_figure_place()
	else:
		combo_counter = 1
	destroyed_line_count += line_count


func _check_bonus_figure_place() -> void:
	if not field.check_figure_collides(bonus_figure_place): return

	var new_score: int = 50
	for block in bonus_figure_place.get_block_positions():
		if field.get_block(block) != Field.EMPTY_VALUE and (field.get_block(block) as Figure.Type) == bonus_figure_place.type:
			new_score = 100

	if bonus_figure_place.is_equal(current_figure):
		new_score = 500

	new_score *= combo_counter
	score += new_score
	bonus_figure_gained.emit(new_score)

	_spawn_bonus_figure_place()


func _spawn_next_figure() -> void:
	current_figure = figure_pool.pop_next_figure()
	current_figure.position = field.spawn_position
	figure_changed.emit()
	next_figure_changed.emit()


func _spawn_bonus_figure_place() -> void:
	var type: Figure.Type = randi_range(0, Figure.Type.MAX - 1) as Figure.Type
	var direction: Figure.Direction = randi_range(0, Figure.Direction.MAX - 1) as Figure.Direction
	var figure: Figure = Figure.new(type, field.spawn_position, direction)
	var position_x: int = randi_range(0, field.size.x - 1)
	var move_direction: Figure.Direction = Figure.Direction.LEFT if position_x <= figure.position.x else Figure.Direction.RIGHT
	while figure.position.x != position_x and _try_move_figure(figure, move_direction): pass
	_drop_figure(figure)
	bonus_figure_place = figure
	bonus_figure_changed.emit()


func _update_score(line_count: int) -> void:
	var new_score: int = 0
	for i in line_count:
		new_score = new_score * 2 + 100
	new_score *= combo_counter
	score += new_score


func _update_speed() -> void:
	speed = 2 + destroyed_line_count / 10 * 0.5
