extends Node
class_name Plus

const plus_texture = preload("res://Assets/Sprites/Plus.png")

var plus

func _init():
	plus = Block.Block_scene.instantiate()

	var plus_sprite = plus.get_node("Block")
	plus_sprite.texture = plus_texture

	plus.z_index = 1

func check_collected(blocks):
	for block in blocks:
		if block.position == plus.position:
			return true

	return false

func check_available_position(locked_blocks, top_border):
	var available_positions = []

	var locked_blocks_coordinates = []

	for block in locked_blocks:
		locked_blocks_coordinates.append(block.position)

	for block in locked_blocks:
		var block_above = Vector2(block.position.x, block.position.y - Block.block_size)
		var block_above_2 = Vector2(block.position.x, block.position.y - 2 * Block.block_size)

		if block_above.y >= top_border and !(block_above in locked_blocks_coordinates) and !(block_above_2 in locked_blocks_coordinates):
			available_positions.append(block_above)

	if len(available_positions) != 0:
		plus.position = available_positions[randi_range(0, len(available_positions) - 1)]
		return true

	return false

func remove():
	plus.queue_free()
