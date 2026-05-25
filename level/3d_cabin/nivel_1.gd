extends Node3D

func _ready() -> void:
	# El mismo protocolo automatizado de escaneo e inyección
	var we_local = find_child("WorldEnvironment", true, false)
	var vhs_local = find_child("VHS_Filter", true, false)
	
	var entorno = we_local.environment if we_local else null
	
	PauseMenu.registrar_y_aplicar_nivel(entorno, vhs_local)
	
	MusicManager.iniciar_playlist_juego()
