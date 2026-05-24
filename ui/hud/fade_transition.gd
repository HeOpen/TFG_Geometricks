extends CanvasLayer

@onready var anim_player = $AnimationPlayer

func transicion_a_escena(ruta_archivo: String) -> void:
	# 1. Hacemos el fundido a negro
	anim_player.play("fade_in")
	await anim_player.animation_finished
	
	# 2. Cambiamos la escena
	get_tree().change_scene_to_file(ruta_archivo)
	
	# 3. Hacemos el fundido a transparente en el nuevo nivel
	anim_player.play("fade_out")
