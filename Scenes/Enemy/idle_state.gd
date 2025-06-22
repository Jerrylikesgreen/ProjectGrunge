class_name IdleState extends EnemyStateMachine

signal player_detected

@onready var idle_timer: Timer = %IdleTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _start_idle_timer()->void:
	idle_timer.start()
	print("_start_idle_timer")
	
	
func _logic_on_idle() -> void:
	if target == null:
		push_error(target,_start_idle_timer )
		_start_idle_timer()
		return

	if target.is_in_group("player"):
		emit_signal("player_detected")

		print("Player Detected",target)
	
	else:## To:do - Replace boilor plate. 
		_start_idle_timer()
		print("_start_idle_timer", "2")
