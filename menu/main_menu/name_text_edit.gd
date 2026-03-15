class_name NameTextEdit extends TextEdit


const MAX_LENGTH: int = 20


func _ready() -> void:
	text = Global.player_name


func _on_text_changed() -> void:
	var caret: int = get_caret_column()
	text = text.substr(0, MAX_LENGTH).strip_edges().replace("\n", "").replace("\r", "")
	set_caret_column(caret)
	Global.player_name = text
