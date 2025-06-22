class_name IdleState extends EnemyStateMachine


@onready var idle_timer: Timer = %Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _start_idle_timer()->void:
	idle_timer.start()
	
	
func _logic_on_idle() -> void:
	if target == null:
		_explore()## To:do - Replace boilor plate. 
		return

	if target._is_player_controlled:
		# on_player_target_state_function
		print("Player Detected",target)
	
	else:## To:do - Replace boilor plate. 
		_start_idle_timer()
