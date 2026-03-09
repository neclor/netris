class_name GameRoot extends Node






@onready var score_label: Label = $Hud/ScoreLabel
@onready var combo_label: Label = $Hud/ComboLabel
@onready var speed_label: Label = $Hud/SpeedLabel






@onready var timer: Timer = %Timer
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var field_node_2d: FieldNode2D = $FieldNode2D


var _game = Game.new()


func _ready() -> void:
	field_node_2d.field = _game.field
	_connect_signals()
	
	_game.start()
	


func _connect_signals() -> void:
	_game.figure_changed.connect(_on_figure_changed)
	_game.next_figure_changed.connect(_on_next_figure_changed)
	_game.hold_figure_changed.connect(_on_hold_figure_changed)
	_game.bonus_figure_changed.connect(_on_bonus_figure_changed)


func _on_timer_timeout():
	_game.step()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left"): _game.try_move_figure(Figure.Direction.LEFT)
	if event.is_action_pressed("right"): _game.try_move_figure(Figure.Direction.RIGHT)
	if event.is_action_pressed("down"): _game.try_move_figure(Figure.Direction.DOWN)
	if event.is_action_pressed("drop"): _game.drop_figure()
	if event.is_action_pressed("rotate_clockwise"): _game.try_rotate_figure(Figure.Rotation.CLOCKWISE)
	if event.is_action_pressed("rotate_counterclockwise"): _game.try_rotate_figure(Figure.Rotation.COUNTERCLOCKWISE)
	if event.is_action_pressed("rotate_180"): _game.try_rotate_figure(Figure.Rotation.ROTATE180)

	if event is InputEventScreenTouch: _screen_touch(event)
	if event is InputEventScreenDrag: _screen_drag(event)


var _touch_position: Vector2 = Vector2.ZERO


func _screen_touch(event: InputEventScreenTouch) -> void:
	_touch_position = event.position
	_game.try_rotate_figure(Figure.Rotation.CLOCKWISE)


func _screen_drag(event: InputEventScreenDrag) -> void:
	if event.velocity.y >= 2000: _game.drop_figure()
	elif event.position.y - _touch_position.y >= 16: _game.try_move_figure(Figure.Direction.DOWN)
	if event.position.x - _touch_position.x <= -16: _game.try_move_figure(Figure.Direction.LEFT)
	elif event.position.x - _touch_position.x >= 16: _game.try_move_figure(Figure.Direction.RIGHT)


func _on_figure_changed() -> void:
	field_node_2d.draw_figure(_game.current_figure, _game.get_ghost_figure())


func _on_next_figure_changed() -> void:
	field_node_2d.draw_next_figure(_game.figure_pool.get_next_figure_type() as int)


func _on_hold_figure_changed() -> void:
	field_node_2d.draw_hold_figure(_game.hold_figure.type if _game.hold_figure != null else -1)


func _on_bonus_figure_changed() -> void:
	field_node_2d.draw_bonus_figure(_game.bonus_figure_place)
