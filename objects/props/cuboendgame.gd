extends StaticBody3D

@onready var anim_cinematica: AnimationPlayer = $AnimationPlayer
const RUTA_CREDITOS: String = "res://ui/credits.tscn"

var texto_interfaz: String = "Interactuar con el cubo [E]"

var activado: bool = false

func interactuar() -> void:
	print("Cubo final tocado. Carga creditos finales")
	if activado:
		return
	activado = true
	
	# 1. Ejecutar animación del encapuchado
	# anim_cinematica.play("ataque_encapuchado")
	
	# 2. Pausar la ejecución de esta función hasta que termine el susto (Jumpscare)
	# await anim_cinematica.animation_finished
	
	# 3. Terminar la partida y cargar créditos
	get_tree().change_scene_to_file(RUTA_CREDITOS)
