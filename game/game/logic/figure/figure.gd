class_name Figure extends RefCounted


enum Type {
	D,
	E,
	Y,
	R,
	I,
	O,
	T,
	J,
	L,
	S,
	Z,
	MAX
}

enum Direction {
	LEFT,
	UP,
	RIGHT,
	DOWN,
	MAX
}

enum Rotation {
	CLOCKWISE,
	COUNTERCLOCKWISE,
	ROTATE180,
	MAX
}

const DATA: Dictionary[Type, Array] = {
	Type.D: [Vector2i(0, 0)],
	Type.E: [Vector2i(0, 0), Vector2i(1, 0)],
	Type.Y: [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
	Type.R: [Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)],
	Type.I: [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	Type.O: [Vector2i(0, 0), Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0)],
	Type.T: [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, -1), Vector2i(1, 0)],
	Type.J: [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
	Type.L: [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, -1), Vector2i(1, 0)],
	Type.S: [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, -1), Vector2i(1, -1)],
	Type.Z: [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)],
}


var type: Type
var position: Vector2i = Vector2i.ZERO
var direction: Direction = Direction.UP


func _init(new_type: Type, new_position: Vector2i = Vector2i.ZERO, new_direction: Direction = Direction.UP) -> void:
	type = new_type
	position = new_position
	direction = new_direction


func move(move_direction: Direction) -> void:
	match move_direction:
		Direction.LEFT: position += Vector2i.LEFT
		Direction.UP: position += Vector2i.UP
		Direction.RIGHT: position += Vector2i.RIGHT
		Direction.DOWN: position += Vector2i.DOWN
		_: pass


func rotate(rotation: Rotation) -> void:
	var i: int = 0
	match rotation:
		Rotation.CLOCKWISE: i = 1
		Rotation.COUNTERCLOCKWISE: i = -1
		Rotation.ROTATE180: i = 2
	direction = (Direction.MAX + direction + i) % Direction.MAX as Direction


func get_block_positions() -> Array[Vector2i]:
	var blocks: Array[Vector2i] = Array(DATA[type].duplicate(), Variant.Type.TYPE_VECTOR2I, "", null)
	match type:
		Type.D, Type.O: pass
		Type.E, Type.Y, Type.I, Type.S, Type.Z:
			match direction:
				Direction.LEFT, Direction.RIGHT: _rotate_blocks(blocks, Rotation.CLOCKWISE)
				_: pass
		_:
			match direction:
				Direction.LEFT: _rotate_blocks(blocks, Rotation.COUNTERCLOCKWISE)
				Direction.RIGHT: _rotate_blocks(blocks, Rotation.CLOCKWISE)
				Direction.DOWN: _rotate_blocks(blocks, Rotation.ROTATE180)
				_: pass
	for i in blocks.size():
		blocks[i] += position
	return blocks


func is_equal(figure: Figure) -> bool:
	if type != figure.type or position != figure.position: return false
	if direction == figure.direction or type in [Type.D, Type.O]: return true

	if type in [Type.E, Type.Y, Type.I, Type.S, Type.Z]:
		var direction_1: Direction = Direction.UP if direction in [Direction.UP, Direction.DOWN] else Direction.RIGHT
		var direction_2: Direction = Direction.UP if figure.direction in [Direction.UP, Direction.DOWN] else Direction.RIGHT
		if direction_1 == direction_2: return true

	return false


func duplicate() -> Figure: 
	return Figure.new(type, position, direction)


func _rotate_blocks(blocks: Array[Vector2i], rotation: Rotation) -> Array[Vector2i]:
	var factor: int = -1 if rotation == Rotation.COUNTERCLOCKWISE else 1
	for i in blocks.size():
		if rotation == Rotation.ROTATE180:
			blocks[i] *= -1
		else:
			var temp: int = blocks[i].x
			blocks[i].x = -blocks[i].y * factor
			blocks[i].y = temp * factor

	return blocks
