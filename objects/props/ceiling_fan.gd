extends StaticBody3D

@onready var animacion_bucle : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animacion_bucle.play("Fan_loop")
