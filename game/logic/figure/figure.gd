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
}

const DATA: Dictionary[Type, FigureData] = {
	Type.D: preload("res://game/logic/figure/figures/d.tres"),
	Type.E: preload("res://game/logic/figure/figures/e.tres"),
	Type.Y: preload("res://game/logic/figure/figures/y.tres"),
	Type.R: preload("res://game/logic/figure/figures/r.tres"),
	Type.I: preload("res://game/logic/figure/figures/i.tres"),
	Type.O: preload("res://game/logic/figure/figures/o.tres"),
	Type.T: preload("res://game/logic/figure/figures/t.tres"),
	Type.J: preload("res://game/logic/figure/figures/j.tres"),
	Type.L: preload("res://game/logic/figure/figures/l.tres"),
	Type.S: preload("res://game/logic/figure/figures/s.tres"),
	Type.Z: preload("res://game/logic/figure/figures/z.tres"),
}


var type: Type
var position: Vector2i = Vector2i.ZERO
var direction: Direction = Direction.UP


func _init(new_type: Type, new_position: Vector2i = Vector2i.ZERO, new_direction: Direction  = Direction.UP) -> void:
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
	direction = (Direction .MAX + direction + i) % Direction.MAX as Direction


func get_block_positions() -> Array[Vector2i]:
	var blocks: Array[Vector2i] = DATA[type].blocks.duplicate()

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

	return blocks


func duplicate() -> Figure: return Figure.new(type, position, direction)


func is_equal(figure: Figure) -> bool:
	if type != figure.type or position != figure.position: return false
	if direction == figure.direction or type in [Type.D, Type.O]: return true

	if type in [Type.E, Type.Y, Type.I, Type.S, Type.Z]:
		var direction_1: Direction = Direction.UP if direction in [Direction.UP, Direction.DOWN] else Direction.RIGHT
		var direction_2: Direction = Direction.UP if figure.direction in [Direction.UP, Direction.DOWN] else Direction.RIGHT
		if direction_1 == direction_2: return true

	return false


func _rotate_blocks(blocks: Array[Vector2i], rotation: Rotation) -> Array[Vector2i]:
	var factor_1: int = -1 if rotation == Rotation.COUNTERCLOCKWISE else 1
	var factor_2: int = -1 if rotation in [Rotation.COUNTERCLOCKWISE, Rotation.ROTATE180] else 1

	for i in blocks.size():
		var temp: int = blocks[i].x
		blocks[i].x = -blocks[i].y * factor_1
		blocks[i].y = temp * factor_2

	return blocks
