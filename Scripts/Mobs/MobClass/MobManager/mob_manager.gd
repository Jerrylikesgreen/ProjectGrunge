class_name MobManager extends Node2D

@onready var mob_body: MobBody = %MobBody
@export var mob_resource: MobResource
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mob_body.connect("mob_state_changed", _on_mob_state_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_mob_state_changed(new_state: MobBody.MobBodyState) -> void:
	match new_state:
		MobBody.MobBodyState.IDLE:      print("Idle")
		MobBody.MobBodyState.MOVING:    print("Moving")
		MobBody.MobBodyState.ACTION:    print("ACTION")
		MobBody.MobBodyState.ATTACKING: print("Attack")
