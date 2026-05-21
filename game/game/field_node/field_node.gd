class_name FieldNode extends Node2D


const ADDITIONAL_LINES: int = 2
const _SOURCE_ID: int = 0


const _NEXT_POSITION: Vector2i = Vector2i(2, -2)
const _HOLD_POSITION: Vector2i = Vector2i(8, -2)


var _field: Field
var _pos_diff: Vector2i = Vector2i.ZERO


@onready var field_tile_map_layer: TileMapLayer = %FieldTileMapLayer
@onready var bonus_figure_tile_map_layer: TileMapLayer = %BonusFigureTileMapLayer
@onready var figure_tile_map_layer: TileMapLayer = %FigureTileMapLayer
@onready var next_figure_tile_map_layer: TileMapLayer = %NextFigureTileMapLayer
@onready var hold_figure_tile_map_layer: TileMapLayer = %HoldFigureTileMapLayer


func init(field: Field) -> void:
	_field = field
	field.field_changed.connect(draw_field)
	_pos_diff = Vector2i(0, field.top_limit - ADDITIONAL_LINES)


func draw_field() -> void:
	if _field == null: return
	field_tile_map_layer.clear()
	for y: int in _field.size.y - _pos_diff.y:
		for x: int in _field.size.x:
			var pos: Vector2i = Vector2i(x, y)
			var field_pos: Vector2i = pos + _pos_diff
			if _field.is_empty(field_pos): continue
			field_tile_map_layer.set_cell(pos, _SOURCE_ID, _get_block_coords(_field.get_block(field_pos) as Figure.Type))


func draw_figure(figure: Figure, ghost_figure: Figure) -> void:
	if _field == null: return
	figure_tile_map_layer.clear()
	if figure == null: return
	for pos: Vector2i in ghost_figure.get_block_positions():
		figure_tile_map_layer.set_cell(pos - _pos_diff, _SOURCE_ID, _get_ghost_block_coords(ghost_figure.type))
	for pos: Vector2i in figure.get_block_positions():
		figure_tile_map_layer.set_cell(pos - _pos_diff, _SOURCE_ID, _get_block_coords(figure.type))


func draw_bonus_figure(figure: Figure) -> void:
	if _field == null: return
	bonus_figure_tile_map_layer.clear()
	if figure == null: return
	for pos: Vector2i in figure.get_block_positions():
		bonus_figure_tile_map_layer.set_cell(pos - _pos_diff, _SOURCE_ID, _get_bonus_block_coords(figure.type))


func draw_next_figure(figure: Figure) -> void:
	next_figure_tile_map_layer.clear()
	if figure == null: return
	for pos: Vector2i in Figure.DATA[figure.type]:
		next_figure_tile_map_layer.set_cell(pos + _NEXT_POSITION, _SOURCE_ID, _get_block_coords(figure.type))


func draw_hold_figure(figure: Figure) -> void:
	hold_figure_tile_map_layer.clear()
	if figure == null:
		return
	for pos: Vector2i in Figure.DATA[figure.type]:
		hold_figure_tile_map_layer.set_cell(pos + _HOLD_POSITION, _SOURCE_ID, _get_block_coords(figure.type))


func _get_block_coords(type: Figure.Type) -> Vector2i:
	return Vector2i(0, type as int)


func _get_ghost_block_coords(type: Figure.Type) -> Vector2i:
	return Vector2i(1, type as int)


func _get_bonus_block_coords(type: Figure.Type) -> Vector2i:
	return Vector2i(7, type as int)
