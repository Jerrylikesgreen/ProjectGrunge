extends Node

signal screen_desat_changed(value: float)   # 0 = colour … 1 = B&W

const PLAYER_DATA := preload("res://Resources/player_data.tres")
var  player_data : PlayerData = PLAYER_DATA.duplicate()

@export_range(0, 9999) var max_emotions : int = 9_999

var _screen_desat: float = 0.0              # private backing store

@export var screen_desat: float = 0.0:      # ← NOTE the colon!
	set(value):
		value = clamp(value, 0.0, 1.0)
		if !is_equal_approx(value, _screen_desat):
			_screen_desat = value
			emit_signal("screen_desat_changed", _screen_desat)
	get:
		return _screen_desat


func emotions_changed(amount: int) -> void:
	if amount <= 0:
		return
	player_data.current_emotions_count = clamp(
		player_data.current_emotions_count + amount,
		0,
		max_emotions
	)
