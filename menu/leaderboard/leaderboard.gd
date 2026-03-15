class_name Leaderboard extends Control


signal quit


@onready var v_box_container: VBoxContainer = %VBoxContainer


func load_leaderboard() -> void:
	var leaderboard: Array[Dictionary] = await Server.load_leaderboard()

	for child in v_box_container.get_children():
		child.queue_free()

	var i: int = 1
	for score in leaderboard:
		var label: Label = Label.new()
		label.text = "%3d. %7d - %s" % [i, int(score["score"]), score["name"]]
		v_box_container.add_child(label)
		i += 1


func _on_back() -> void:
	hide()
	quit.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"): _on_back()
