class_name Main extends Node


@onready var main_menu: CanvasLayer = $MainMenu
@onready var game_root: GameRoot = $GameRoot


func _ready() -> void:
	game_root.hide_all()
	get_tree().paused = true


func _on_game_root_back() -> void:
	get_tree().paused = true
	game_root.hide_all()
	main_menu.show()


func _on_play_button_pressed():
	get_tree().paused = false
	game_root.show_all()
	main_menu.hide()
