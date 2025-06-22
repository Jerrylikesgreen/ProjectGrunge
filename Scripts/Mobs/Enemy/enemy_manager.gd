class_name EnemyManager extends MobManager     

@onready var fsm    : EnemyStateMachine  = $EnemyController/EnemyStateMachine
@onready var vision: Area2D = %Vision


enum EnemyState { IDLE, MOVING, ACTION, ATTACKING, CHASE }

var _state_history : Array[EnemyState] = []
var current_state  : EnemyState = EnemyState.IDLE : set = _set_state

var _current_target : Vector2 = Vector2.ZERO

# --------------------------[READY]---------------------------------------- 

func _ready() -> void:
	await get_tree().process_frame 
	vision = find_child("VisionArea", true, false)
	if not vision:
		push_error("VisionArea not found!")
		return
	vision.body_shape_entered.connect(_on_vision_body_entered)


# -------------------------------[LOGGER]----------------------------------- 
func _on_mob_body_state_changed(new_state : MobBody.MobBodyState) -> void:
	_push_history(EnemyState.values()[int(new_state)])   ## 1-to-1
	print("Enemy Body entered:", new_state,
		  "  (history:", _state_history, ")")

func _push_history(s : EnemyState, max_len := 20) -> void:
	_state_history.push_back(s)
	if _state_history.size() > max_len:
		_state_history.pop_front()

# ------------------------[VISION / AGGRO]------------------------------------------ 
func _on_vision_body_entered(
		body_rid          : RID,
		body              : Node2D,
		body_shape_index  : int,
		local_shape_index : int
	) -> void:

	if body.is_in_group("player"):
		_current_target = body.global_position
		fsm.on_player_target(_current_target)
		current_state = EnemyState.CHASE

# ----------------------------[PRIVATE SETTER]-------------------------------------- 
func _set_state(new_state : EnemyState) -> void:
	if new_state == current_state:
		return
	current_state = new_state


func _on_enemy_state_machine_explore() -> void:
	if !vision:
		
	vision.set_visible(true)
	print(true)
	pass # Replace with function body.
