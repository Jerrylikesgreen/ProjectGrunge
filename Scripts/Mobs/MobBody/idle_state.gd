class_name IdleState extends Node  

signal detected_target

const IDLE_TIMER_SCN := preload("res://Scenes/Enemy/idle_timer.tscn")


var idle_timer: Timer

# -----------------------------------[READY]------------------------------- 
func _ready() -> void:
	idle_timer = IDLE_TIMER_SCN.instantiate()
	idle_timer.wait_time = 2.0  
	idle_timer.one_shot  = true
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	add_child(idle_timer)

	_start_idle_timer()


func _start_idle_timer() -> void:
	idle_timer.start()    

func _on_idle_timer_timeout() -> void:
	_logic_on_idle()

func _logic_on_idle() -> void:
		_start_idle_timer()
		emit_signal("detected_target")
		print("dsdsd")
