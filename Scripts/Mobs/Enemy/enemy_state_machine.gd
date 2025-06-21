class_name EnemyStateMachine extends Node

signal explore


enum EnemyState { IDLE, EXPLORING, PLAYER_TARGET }

@export var state : EnemyState = EnemyState.IDLE : set = _set_state

@onready var on_player_target_state: Node = $OnPlayerTargetState

@export var target: MobBody



func _ready() -> void:
	
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass



func _logic_on_idle() -> void:
	if target == null:
		_explore()## To:do - Replace boilor plate. 
		return

	if target._is_player_controlled:
		on_player_target_state
	
	else:## To:do - Replace boilor plate. 
		_explore()


func _explore():
	
	pass 
	
func _set_state(new_state : EnemyState) -> void:
	if new_state == state:
		return                           

	state = new_state
