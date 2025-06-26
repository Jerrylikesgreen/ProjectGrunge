class_name EmotionsComponent
extends Node2D

@export var max_emotions: int = 100

var _current: int = 0

@export var current_emotions: int = 0:
	set(value):
		_current = clamp(value, 0, max_emotions)
	get:
		return _current


func _ready() -> void:
	current_emotions = 0


func add_emotions(amount: int) -> void:
	if amount <= 0:
		return
	current_emotions += amount
	Globals.emotions_changed(amount)

func remove_emotions(amount: int) -> void:
	if amount <= 0:
		return
	current_emotions -= amount
	Globals.emotions_changed(-amount)
