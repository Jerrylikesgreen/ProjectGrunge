class_name EnemyManager
extends Node2D

@export var mob_resource: MobResource 

@onready var mob_body: MobBody = %MobBody
@onready var enemy_state_machine: EnemyStateMachine = $EnemyControler/EnemyStateMachine
@onready var vision: Area2D = %Area2D

var prior_states: Array[MobBody.MobBodyState] = []
var _current_target: Vector2


func _ready() -> void:
	mob_body.mob_state_changed.connect(_on_mob_body_state_changed)

func _on_mob_body_state_changed(new_state: MobBody.MobBodyState) -> void:
	_push_state_history(new_state)
	print("Enemy entered state:", new_state, "  (history:", prior_states, ")")

func _push_state_history(s: MobBody.MobBodyState, max_len := 20) -> void:
	prior_states.push_back(s)
	if prior_states.size() > max_len:
		prior_states.pop_front()

func _on_area_2d_body_shape_entered(
	body_rid: RID, 
	body: Node2D, 
	body_shape_index: int, 
	local_shape_index: int
	) -> void:
		
	if body.is_in_group("player"):
		_current_target = body.global_position
		enemy_state_machine.on_player_target(_current_target)
		return


func _on_enemy_state_machine_explore() -> void:
	if !vision.is_visible():
		pass
	else:
		vision.set_visible(true)
	pass # Replace with function body.
