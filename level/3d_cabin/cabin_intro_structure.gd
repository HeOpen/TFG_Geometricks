extends Node3D

func _ready() -> void:
	$Fade_transition/Fade_timer.start()
	$Fade_transition/AnimationPlayer.play("fade_out")


func _on_fade_timer_timeout() -> void:
	$Fade_transition.hide()
