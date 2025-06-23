class_name EnemyStateMachine extends Node

signal explore                          # Manager → start wandering
signal chase                            # Manager → chase this point
signal lost_target                      # Manager → revert to idle
signal attacking

enum EnemyState { IDLE, EXPLORING, CHASE, ATTACKING }
@export var state : EnemyState = EnemyState.IDLE : set = _set_state
@onready var chase_state: ChaseState = %ChaseState
@onready var idle_state: IdleState = %IdleState
@onready var attacking_state: Node = %AttackingState

@onready var templabel: Label = %Label


@export var target: MobBody



func _process(_delta: float) -> void:
	templabel.set_text(str(state))

func _explore():
	pass 
	
func _set_state(new_state : EnemyState) -> void:
	if new_state == state:
		return                           

	state = new_state
	if state == EnemyState.ATTACKING:
		pass
		attacking_state.run_attacking_logic


func _on_idle_timer_timeout() -> void:
	_set_state(EnemyState.EXPLORING)
	emit_signal("explore")

func on_player_spotted(pos: Vector2) -> void:
	_set_state(EnemyState.CHASE)
	emit_signal("chase")


func on_target_lost() -> void:
	_set_state(EnemyState.IDLE)
	emit_signal("lost_target")
