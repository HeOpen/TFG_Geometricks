extends Node3D

func _ready() -> void:
	# 1. Buscamos los componentes locales de este mapa de forma segura
	var we_local = find_child("WorldEnvironment", true, false)
	var vhs_local = find_child("VHS_Filter", true, false)
	
	var entorno = we_local.environment if we_local else null
	
	# 2. Exigimos al Autoload que aplique los valores guardados a esta escena
	PauseMenu.registrar_y_aplicar_nivel(entorno, vhs_local)
	
	MusicManager.reproducir_intro()
