class_name EnemyControler extends Node2D

@onready var mob_body: MobBody = %MobBody



func _set_horizontal_movement(dir:float)->void:
	mob_body.set_horizontal_input(dir)
	pass
