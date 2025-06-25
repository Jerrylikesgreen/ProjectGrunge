class_name LevelManager extends Node2D

@onready var player: PlayerManager = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enemy_update_player_score(value: int) -> void:
	player.emotions_score.set_text(str(value))
	print(value, "Plaplpldaspla")
	pass # Replace with function body.
