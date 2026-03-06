class_name Block extends RefCounted


var figure_type: Figure.Type = Figure.Type.D
var color: Color:
	get: return get_color()


func _init(new_figure_type: Figure.Type):
	figure_type = new_figure_type


func get_color() -> Color: return Figure.DATA[figure_type].color
