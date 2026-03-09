class_name FigurePool extends RefCounted


var _pool: Array[Figure.Type] = []


func _init() -> void:
	refill()


func get_next_figure_type() -> Figure.Type: 
	return _pool.back()


func pop_next_figure() -> Figure:
	var next_figure: Figure = Figure.new(_pool.pop_back())
	if (_pool.is_empty()): refill()
	return next_figure


func refill() -> void:
	_pool = []
	for i: int in range(Figure.Type.MAX):
		_pool.append(i as Figure.Type)
	_pool.shuffle()
