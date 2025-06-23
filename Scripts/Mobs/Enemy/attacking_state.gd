class_name AttackingState extends EnemyStateMachine


signal keep_attacking

var _attacking_state_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func run_attacking_logic()-> void:
	_attacking_state_active = true
	pass
