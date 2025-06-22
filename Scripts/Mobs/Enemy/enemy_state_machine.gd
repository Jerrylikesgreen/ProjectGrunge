class_name EnemyStateMachine extends Node

signal explore


enum EnemyState { IDLE, EXPLORING, PLAYER_TARGET }

@export var state : EnemyState = EnemyState.IDLE : set = _set_state

@onready var player_target_state: PlayerTargetState = %PlayerTargetState
@onready var idle_state: IdleState = %IdleState

@export var target: MobBody
@export var target_pos: Vector2


func _ready() -> void:
	idle_state._logic_on_idle()



func _process(delta: float) -> void:
	pass



func _explore():
	
	pass 
	
func _set_state(new_state : EnemyState) -> void:
	if new_state == state:
		return                           

	state = new_state


func _on_idle_timer_timeout() -> void:
	_set_state(EnemyState.EXPLORING)
