class_name EnemyStateMachine extends Node

signal explore

@onready var debug_label: Label = $Label

enum EnemyState { IDLE, EXPLORING, CHASE }
@export var state : EnemyState = EnemyState.IDLE : set = _set_state

@onready var player_target_state: PlayerTargetState = %PlayerTargetState
@onready var idle_state: IdleState = %IdleState



@export var target: MobBody


func _ready() -> void:
	idle_state._logic_on_idle()

func _process(delta: float) -> void:
	debug_label.set_text(str(state))

func _explore():
	pass 
	
func _set_state(new_state : EnemyState) -> void:
	if new_state == state:
		return                           

	state = new_state


func _on_idle_timer_timeout() -> void:
	_set_state(EnemyState.EXPLORING)
	emit_signal("explore")


func _on_idle_state_player_detected() -> void:
	_set_state(EnemyState.CHASE)
	pass # Replace with function body.
