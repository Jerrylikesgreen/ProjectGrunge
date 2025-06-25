class_name LevelManager
extends Node2D

@onready var player: PlayerManager = %Player


func _process(_delta: float) -> void:
	# protect against divide-by-zero just in case
	var emotion_ratio := 0.0
	if player.max_emotions_count > 0:
		emotion_ratio = clamp(
			float(player.current_emotions_count) / player.max_emotions_count,
			0.0, 1.0
		)

	# 0 = colour, 1 = B&W → invert if you want colour to fade *out*
	Globals.screen_desat = emotion_ratio
