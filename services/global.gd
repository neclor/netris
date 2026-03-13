@abstract class_name Global extends Node


static var player_name: String = Saver.load_name():
	set  = set_player_name


static func set_player_name(value: String) -> void:
	player_name = value
	Saver.save_name(player_name)
