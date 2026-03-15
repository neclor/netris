class_name MainMenu extends CanvasLayer


@onready var leaderboard: Leaderboard = %Leaderboard


func _on_leaderboard_button_pressed():
	leaderboard.show()
	leaderboard.load_leaderboard()
	leaderboard.process_mode = Node.PROCESS_MODE_INHERIT


func _on_leaderboard_quit():
	leaderboard.hide()
	leaderboard.process_mode = Node.PROCESS_MODE_DISABLED
