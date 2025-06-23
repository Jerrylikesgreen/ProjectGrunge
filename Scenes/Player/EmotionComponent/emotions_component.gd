extends Node2D

@export var max_emotions: int = 10

var current_emotions: int :
	get:
		return current_emotions
	set(value):
		if value < 0:
			value = 0
		elif value > max_emotions:
			value = max_emotions
		current_emotions = value

func _ready() -> void:
	current_emotions = max_emotions

func add_emotions(amount: int) -> void:
	current_emotions = current_emotions + amount

func remove_emotions(amount: int) -> void:
	current_emotions = current_emotions - amount
