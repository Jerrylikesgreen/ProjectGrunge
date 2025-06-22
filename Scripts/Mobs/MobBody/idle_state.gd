class_name IdleState extends EnemyStateMachine


const IDLE_TIMER = preload("res://Scenes/Enemy/idle_timer.tscn")
var idle_timer:Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	idle_timer = IDLE_TIMER.instantiate()
	add_child(idle_timer)
	_logic_on_idle
	print(_logic_on_idle)
	pass


func _process(_delta: float) -> void:
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
