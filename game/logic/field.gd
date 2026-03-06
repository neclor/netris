class_name Field extends RefCounted


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


func get_block(position: Vector2i) -> Block:
	return _field[position.y][position.x]


func set_block(position: Vector2i, block: Block) -> void:
	_field[position.y][position.x] = block


func place_figure(figure: Figure) -> void:
	for block in figure.get_block_positions():
		_field[block.y][block.x] = Block.new(figure.type)


func destroy_lines() -> int:
	var line_count: int = 0
	for row in range(_field.size() - 1, -1, -1):
		if _field[row].has(null): continue
		line_count += 1
		_field.remove_at(row)
		_field.push_front([])
		_field[0].resize(size.x)
	return line_count


func check_figure_collides(figure: Figure) -> bool:
	for block in figure.get_block_positions():
		if block.x < 0 or size.x <= block.x or \
			size.y <= block.y or \
			_field[block.y][block.x] != null: return true
	return false


func check_game_over() -> bool:
	for y in range(top_limit):
		if _field[y].any(func(block: Block) -> bool: return block != null):
			return true
	return false


func clear() -> void:
	for row in _field:
		row.fill(null)
