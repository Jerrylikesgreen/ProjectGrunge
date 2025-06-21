class_name EnemyManager
extends Node2D

@export var mob_resource: MobResource 

@onready var mob_body: MobBody = %MobBody

var prior_states: Array[MobBody.MobBodyState] = []

func _ready() -> void:
	mob_body.mob_state_changed.connect(_on_mob_body_state_changed)

func _on_mob_body_state_changed(new_state: MobBody.MobBodyState) -> void:
	prior_states.push_back(new_state)
	# limit the length so it doesn't grow forever ???? Thoughts. 
	if prior_states.size() > 20:
		prior_states.pop_front()

	# Example debug
	print("Enemy entered state: ", new_state, "  (history: ", prior_states, ")")
