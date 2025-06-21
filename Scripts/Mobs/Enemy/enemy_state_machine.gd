class_name EnemyStateMachine extends Node

signal explore


const MobBodyState = MobBody.MobBodyState
@onready var on_player_target_state: Node = $OnPlayerTargetState

@export var mob_state: MobBodyState = MobBodyState.IDLE
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
