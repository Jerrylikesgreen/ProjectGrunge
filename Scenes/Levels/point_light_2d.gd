extends PointLight2D


@onready var mat := material as ShaderMaterial    # cache & cast once

func _ready() -> void:
	_on_desat_changed(Globals.screen_desat)              # initialise
	Globals.connect("screen_desat_changed", _on_desat_changed)


func _on_desat_changed(val: float) -> void:
	mat.set_shader_parameter("colorize", val)            # or 1.0 - val
