class_name LevelManager
extends Node2D

@onready var effect_rect: ColorRect    = $BackgroundLayer/MonochromeEffect
@onready var mat: ShaderMaterial       = effect_rect.material as ShaderMaterial
@onready var player: PlayerManager = %Player


func _on_enemy_update_player_score(current_emotion_count: int) -> void:
	var comp := player.emotions_component
	var ratio := 0.0
	if comp.max_emotions > 0:
		ratio = clamp(float(current_emotion_count) / comp.max_emotions, 0.0, 1.0)
	mat.set_shader_parameter("colorize", ratio)
	print(
	"cur:", player.emotions_component.current_emotions,
	"  max:", player.emotions_component.max_emotions
)
	player.emotions_score.set_text(str(current_emotion_count))

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
