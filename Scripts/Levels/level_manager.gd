class_name LevelManager extends Node2D


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
