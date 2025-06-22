class_name PlayerManager extends MobManager



var prior_states: Array[MobBody.MobBodyState] = []

func _ready() -> void:
	mob_body.add_to_group("player")

func _on_mob_body_state_changed(new_state: MobBody.MobBodyState) -> void:
	prior_states.push_back(new_state)

	if prior_states.size() > 20:
		prior_states.pop_front()

	print("Player entered state: ", new_state, "  (history: ", prior_states, ")")
