class_name PlayerManager extends MobManager

@export var emotions_component: Node2D
@export var body: MobBody 
var prior_states: Array[MobBody.MobBodyState] = []

@onready var emotions_score: Label = %EmotionsScore


var current_emotions_count:int = 0
var max_emotions_count:int= 100

func _ready() -> void:
	mob_body.add_to_group("player")
	mob_body.set_collision_layer(1)
	mob_body.set_collision_mask(30)
	mob_body._is_player_controled = true

func _on_mob_body_state_changed(new_state: MobBody.MobBodyState) -> void:
	prior_states.push_back(new_state)

	if prior_states.size() > 20:
		prior_states.pop_front()

	print("Player entered state: ", new_state, "  (history: ", prior_states, ")")


func _on_enemy_update_player_score() -> void:
	emotions_score.update_score()
	print("Signal received from player")
