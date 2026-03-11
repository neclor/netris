class_name FigurePool extends RefCounted


signal next_figure_changed(figure: Figure)


var _pool: Array[Figure.Type] = []


func _init() -> void:
	refill()


func get_next_figure() -> Figure: 
	return Figure.new(_pool.back())


func pop_next_figure() -> Figure:
	var next_figure: Figure = Figure.new(_pool.pop_back())
	if (_pool.is_empty()):
		refill()
	next_figure_changed.emit(get_next_figure())
	return next_figure


func refill() -> void:
	_pool = []
	for i: int in Figure.Type.MAX as int:
		_pool.append(i as Figure.Type)
	_pool.shuffle()
