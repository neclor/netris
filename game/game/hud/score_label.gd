class_name ScoreLabel extends Label


var _old_value: int = 0
var _desired_value: int = 0


static func decay_weight(decay: float, delta: float) -> float:
	return 1 - exp(-decay * delta)


func _process(delta: float) -> void:
	if _old_value == _desired_value: return
	_old_value = ceili(lerp(_old_value, _desired_value, decay_weight(10, delta)))
	text = "Score: " + str(_old_value)


func set_score(value: int) -> void:
	_desired_value = value
