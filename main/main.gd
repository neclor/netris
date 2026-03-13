class_name Main extends Node


@onready var main_menu: CanvasLayer = $MainMenu
@onready var game_root: GameRoot = $GameRoot


func _on_game_root_back() -> void:
	get_tree().paused = true
	game_root.hide_all()
	main_menu.show()
