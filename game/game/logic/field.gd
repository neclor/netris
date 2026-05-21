class_name Field extends RefCounted


signal field_changed


const EMPTY_VALUE: int = -1


var size: Vector2i = Vector2i(12, 28)
var top_limit: int = 4
var spawn_position: Vector2i = Vector2i(5, 3)


var _field: Array[Array] = []


func _init(new_size: Vector2i = size, new_top_limit: int = top_limit, new_spawn_position: Vector2i = spawn_position) -> void:
	size = new_size
	top_limit = new_top_limit
	spawn_position = new_spawn_position
	_field.resize(size.y)
	for row in _field:
		row.resize(size.x)
	clear()


func get_block(position: Vector2i) -> int:
	return _field[position.y][position.x]


func set_block(position: Vector2i, block: int) -> void:
	_field[position.y][position.x] = block
	field_changed.emit()


func is_empty(position: Vector2i) -> bool:
	return _field[position.y][position.x] == EMPTY_VALUE


func place_figure(figure: Figure) -> void:
	for block in figure.get_block_positions():
		_field[block.y][block.x] = figure.type as int
	field_changed.emit()


func destroy_lines() -> int:
	var line_count: int = 0
	for i in _field.size():
		if _field[i].has(EMPTY_VALUE): continue
		line_count += 1
		_field.remove_at(i)
		_field.push_front([])
		_field[0].resize(size.x)
		_field[0].fill(EMPTY_VALUE)
	if line_count != 0: field_changed.emit()
	return line_count


func check_figure_collides(figure: Figure) -> bool:
	for block in figure.get_block_positions():
		if block.x < 0 or size.x <= block.x or size.y <= block.y or _field[block.y][block.x] != EMPTY_VALUE: return true
	return false


func check_game_over() -> bool:
	for y in range(top_limit):
		if _field[y].any(func(block: int) -> bool: return block != EMPTY_VALUE):
			return true
	return false


func clear() -> void:
	for row in _field:
		row.fill(EMPTY_VALUE)
	field_changed.emit()
