class_name LevelManager
extends Node2D

@onready var effect_rect: ColorRect = %effect_rect
@onready var player      : PlayerManager = %Player
var mat: ShaderMaterial

func _ready() -> void:
	# Give this rect its own copy so no one else overwrites it
	effect_rect.material = effect_rect.material.duplicate()
	mat = effect_rect.material as ShaderMaterial

	# Initial sync
	_apply_ratio(player.emotions_component.current_emotions)

func _on_enemy_update_player_score(new_total: int) -> void:
	_apply_ratio(new_total)
	player.emotions_score.text = str(new_total)

func _apply_ratio(cur: int) -> void:
	var max_emotions = player.emotions_component.max_emotions
	var ratio := 0.0
	if max_emotions > 0:
		ratio = clamp(float(cur) / max_emotions, 0.0, 1.0)
	mat.set_shader_parameter("colorize", ratio)  
	Globals.screen_desat = ratio                 
