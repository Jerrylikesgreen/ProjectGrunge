class_name EnemyControler extends Node2D

@onready var mob_body: MobBody = %MobBody


func _ready() -> void:
	pass # Replace with function body.



func _process(delta: float) -> void:
	pass



func _set_horizontal_movement(dir:float)->void:
	mob_body.set_horizontal_input(dir)
	pass
