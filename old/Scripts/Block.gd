extends Node2D

const Block_scene = preload("res://Scenes/Block.tscn")
const block_texture = preload("res://Assets/Sprites/Block.png")

const block_size = 32

const interior_old_color = Color("#ff0000")
const external_old_color = Color("#00ff00")

func change_color(block_sprite, interior_new_color, external_new_color):
	var new_block_image = block_texture.get_image()

	for x in block_size:
		for y in block_size:

			if new_block_image.get_pixel(x, y) == interior_old_color:
				new_block_image.set_pixel(x, y, interior_new_color)

			if new_block_image.get_pixel(x, y) == external_old_color:
				new_block_image.set_pixel(x, y, external_new_color)

	var new_texture = ImageTexture.create_from_image(new_block_image)
	block_sprite.texture = new_texture
