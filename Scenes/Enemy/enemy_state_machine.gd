class_name EnemyStateMachine extends Node


const MobBodyState = MobBody.MobBodyState

@export var mob_state: MobBodyState = MobBodyState.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mob_body__on_mob_body_state_change(mob_body_state: MobBody.MobBodyState) -> void:
	mob_state = mob_body_state
	pass # Replace with function body.
