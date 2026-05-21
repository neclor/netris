class_name GameRoot extends Node2D


signal back


@onready var timer: Timer = %Timer
@onready var field_node_2d: FieldNode = $FieldNode

@onready var hud: CanvasLayer = $Hud

@onready var score_label: ScoreLabel = $Hud/MarginContainer/HBoxContainer/ScoreLabel
@onready var combo_label: ComboLabel = $Hud/MarginContainer/HBoxContainer/ComboLabel

@onready var back_button: TextureButton = $Hud/MarginContainer/ButtonContainer/BackButton
@onready var pause_button: TextureButton = $Hud/MarginContainer/ButtonContainer/PauseButton
@onready var swap_button: TextureButton = $Hud/MarginContainer/ButtonContainer/SwapButton

@onready var game_over_container: VBoxContainer = $Hud/CenterContainer/GameOverContainer


var _game: Game = Game.new()


func hide_all() -> void:
	hide()
	hud.hide()


func show_all() -> void:
	show()
	hud.show()


func _ready() -> void:
	field_node_2d.init(_game.field)
	_connect_signals()
	_on_start()


func _connect_signals() -> void:
	_game.score_changed.connect(score_label.set_score)
	_game.combo_counter_changed.connect(combo_label.set_combo)
	_game.speed_changed.connect(_on_speed_changed)

	_game.current_figure_changed.connect(_on_current_figure_changed)
	_game.figure_pool.next_figure_changed.connect(field_node_2d.draw_next_figure)
	_game.hold_figure_changed.connect(field_node_2d.draw_hold_figure)
	_game.bonus_figure_changed.connect(field_node_2d.draw_bonus_figure)
	_game.swap_allowed_changed.connect(_on_swap_allowed_changed)

	_game.paused_changed.connect(_on_paused_changed)
	_game.game_over.connect(_on_game_over)


func _on_start() -> void:
	game_over_container.hide()
	_game.init()
	_game.start()
	_on_speed_changed(_game.speed)


func _on_speed_changed(speed: float) -> void:
	timer.stop()
	timer.start(1.0 / speed)


func _on_timer_timeout():
	_game.step()


func _on_current_figure_changed(figure: Figure) -> void:
	field_node_2d.draw_figure(figure, _game.get_ghost_figure())


func _on_swap_allowed_changed(allowed: bool) -> void:
	swap_button.button_pressed = not allowed


func _on_game_over() -> void:
	Server.send_score(Global.player_name, _game.score)
	game_over_container.show()


func _on_paused_changed(paused: bool) -> void:
	timer.paused = paused
	back_button.visible = paused
	pause_button.button_pressed = paused


func _on_pause_button_pressed() -> void:
	_game.paused = not _game.paused
	pause_button.button_pressed = _game.paused


func _on_swap_button_pressed() -> void:
	_game.try_swap_figure()
	swap_button.button_pressed = not _game.swap_allowed


func _on_back() -> void:
	_game.paused = true
	back.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"): _game.paused = not _game.paused
	
	if Input.is_action_pressed("left"): _game.try_move_figure(Figure.Direction.LEFT)
	if Input.is_action_pressed("right"): _game.try_move_figure(Figure.Direction.RIGHT)
	if Input.is_action_pressed("down"): _game.try_move_figure(Figure.Direction.DOWN)
	if event.is_action_pressed("drop"): _game.drop_figure()
	if event.is_action_pressed("rotate_clockwise"): _game.try_rotate_figure(Figure.Rotation.CLOCKWISE)
	if event.is_action_pressed("rotate_counterclockwise"): _game.try_rotate_figure(Figure.Rotation.COUNTERCLOCKWISE)
	if event.is_action_pressed("rotate_180"): _game.try_rotate_figure(Figure.Rotation.ROTATE180)
	if event.is_action_pressed("swap"): _game.try_swap_figure()

	if event is InputEventScreenTouch: _screen_touch(event)
	if event is InputEventScreenDrag: _screen_drag(event)

	if event.is_action("ui_cancel"): _on_back()


var _new_touch: bool = true
var _is_drag: bool = false
var _drag_dropped: bool = false
var _touch_position: Vector2 = Vector2.ZERO


func _screen_touch(event: InputEventScreenTouch) -> void:
	if _new_touch:
		_touch_position = event.position
	_new_touch = false
	if not event.pressed:
		if not _is_drag:
			_game.try_rotate_figure(Figure.Rotation.CLOCKWISE)
		_new_touch = true
		_is_drag = false
		_drag_dropped = false


func _screen_drag(event: InputEventScreenDrag) -> void:
	var screen: Vector2 = get_viewport_rect().size
	var step: Vector2 = Vector2(screen.x * 0.05, screen.y * 0.05)
	var drop_velocity: float = screen.y * 1.5
	_is_drag = true
	var delta: Vector2i = event.position - _touch_position
	if event.velocity.y >= drop_velocity and not _drag_dropped:
		_game.drop_figure()
		_drag_dropped = true
		return

	if delta.x > step.x: 
		_game.try_move_figure(Figure.Direction.RIGHT)
		_touch_position.x += step.x
	elif delta.x < -step.x:
		_game.try_move_figure(Figure.Direction.LEFT)
		_touch_position.x -= step.x
	elif delta.y > step.y:
		_game.try_move_figure(Figure.Direction.DOWN)
		_touch_position.y += step.y
