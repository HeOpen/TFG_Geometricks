extends AnimatableBody2D

func desaparecer(duracion: float = 0.5) -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duracion)
	tween.tween_callback(queue_free)
