extends Node

const PLAYER_DATA = preload("res://Resources/player_data.tres")
var player_data: PlayerData = PLAYER_DATA.duplicate()


@export_range(0, 9999) var max_emotions := 9999


 
func emotions_changed(amount: int) -> void:
	if amount <= 0:
		return
	player_data.current_emotions_count = clamp(
		player_data.current_emotions_count + amount,
		0,
		max_emotions
	)
