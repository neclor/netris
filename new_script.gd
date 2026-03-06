@tool 
extends EditorScript







func _run() -> void:
	var a: FigureData = preload("res://game/logic/figure/figures/d.tres")
	
	
	
	print(a.blocks)
	
	
	a.blocks = []
	
	print(a.blocks)
	
