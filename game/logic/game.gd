class_name Game extends RefCounted


signal score_changed(value: int)
signal destroyed_line_count_changed(value: int)

signal figure_moved



var score: int = 0
var destroyed_line_count: int = 0
var speed: float = 1

var field_size: Vector2i = Vector2i(12, 24)
var current_figure: Figure = null

var game_over: bool = false

var _field: Array[Array] = [] # Array[Array[Block?]]
var _figure_pool: Array[Figure.Type] = _new_figure_pool()


func _init(new_size: Vector2i = field_size) -> void:
	field_size = new_size
	_field.resize(field_size.y)
	for row in _field:
		row.resize(field_size.x)
	current_figure = pop_next_figure()


func step() -> void:
	if game_over: return
	if try_move_figure(Figure.Direction.DOWN): return
	_place_figure()
	
	
	
	pass


func try_move_figure(direction: Figure.Direction) -> bool: return _try_move_figure(current_figure, direction)


func try_rotate_figure(rotation: Figure.Rotation) -> bool:
	var new_figure: Figure = current_figure.duplicate()
	var initial_position: Vector2i = figure.position
	var initial_direction: Figure.Direction = figure.direction

	var rotation_list: Array[Figure.Rotation] = []
	match rotation:
		Figure.Rotation.CLOCKWISE: rotation_list = [Figure.Rotation.CLOCKWISE, Figure.Rotation.ROTATE180, Figure.Rotation.COUNTERCLOCKWISE]
		Figure.Rotation.COUNTERCLOCKWISE: rotation_list = [Figure.Rotation.COUNTERCLOCKWISE, Figure.Rotation.ROTATE180, Figure.Rotation.CLOCKWISE]
		Figure.Rotation.ROTATE180: rotation_list = [Figure.Rotation.ROTATE180, Figure.Rotation.CLOCKWISE, Figure.Rotation.COUNTERCLOCKWISE] 
		_: rotation_list = []

	var offset_list: Array[Vector2i] = [Vector2i.ZERO, Vector2i.RIGHT, Vector2i.LEFT]
	if current_figure.type == Figure.Type.I:
		offset_list += [Vector2i.RIGHT * 2, Vector2i.LEFT * 2]

	for r in rotation_list:
		new_figure.direction = initial_direction
		new_figure.rotate(r)
		for offset in offset_list:
			new_figure.position = initial_position + offset
			if _check_figure_collides(new_figure): continue
			current_figure = new_figure
			return true
	return false


func get_shadow_figure() -> Figure:
	var new_figure: Figure = current_figure.duplicate()
	while not _check_figure_collides(new_figure):
		new_figure.position += Vector2i.DOWN
	new_figure.position += Vector2i.UP
	return new_figure


func get_next_figure_type() -> Figure.Type:
	return _figure_pool.back()


func pop_next_figure() -> Figure:
	var next_figure: Figure = Figure.new(_figure_pool.pop_back())
	if (_figure_pool.is_empty()):
		_figure_pool = _new_figure_pool()
	return next_figure


func _try_move_figure(figure: Figure, direction: Figure.Direction) -> bool:
	var new_figure: Figure = figure.duplicate()
	new_figure.move(direction)
	if _check_figure_collides(new_figure): return false
	figure.move(direction)
	return true


func _check_figure_collides(figure: Figure) -> bool:
	for block in figure.get_block_positions():
		if block.x < 0 or field_size.x <= block.x or \
			field_size.y <= block.y or \
			_field[block.y][block.x] != null: return true
	return false


func _place_figure() -> void:
	for block in figure.get_block_positions():
		_field[block.y][block.x] = Block.new(figure.type)


func _new_figure_pool() -> Array[Figure.Type]:
	var new_figure_pool: Array[Figure.Type] = []
	for i: int in range(Figure.Type.MAX):
		new_figure_pool.append(i as Figure.Type)
	new_figure_pool.shuffle()
	return new_figure_pool
