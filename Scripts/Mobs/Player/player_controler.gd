class_name PlayerControler extends Node2D

@onready var body: MobBody = %MobBody


func _physics_process(_delta: float) -> void:
	# Horizontal axis (–1, 0, +1)
	var dir := Input.get_axis("Left", "Right")
	body.set_horizontal_input(dir)
	
	# Jump request (edge-trigger)
	if Input.is_action_just_pressed("Up"):
		body.request_jump()

	if Input.is_action_just_pressed("Attack"):
		body.attack()

	if Input.is_action_just_pressed("Attack"):
		body.attack()
