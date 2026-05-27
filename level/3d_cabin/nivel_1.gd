extends Node3D

@onready var game_timer: Timer = $Timer_CuentraAtras15

const RUTA_GAME_OVER: String = "res://ui/GameOver_Screen.tscn"

func _ready() -> void:
	# Busca a las variables puestas en el menu/pausa y lo aplica a la escena actual
	var we_local = find_child("WorldEnvironment", true, false)
	var vhs_local = find_child("VHS_Filter", true, false)
	
	var entorno = we_local.environment if we_local else null
	
	PauseMenu.registrar_y_aplicar_nivel(entorno, vhs_local)
	
	MusicManager.iniciar_playlist_juego()
	_configurar_e_iniciar_temporizador()
	
func _configurar_e_iniciar_temporizador() -> void:
	# Chuleta tiempo
	# 15 (min) * 60 segundos = 900.0 segundos
	# 10 segundos * 60 segundos = 6.0 segundos
	game_timer.wait_time = 6.0
	
	# Aseguramos que el temporizador no se ejecute en bucle infinito
	game_timer.one_shot = true
	
	# Conexión segura de la señal nativa por código
	if not game_timer.timeout.is_connected(_on_timer_timeout):
		game_timer.timeout.connect(_on_timer_timeout)
		
	game_timer.start()

func congelar_temporizador_sotano() -> void:
	# Esta función pública será invocada cuando el jugador interactúe con el sótano
	if game_timer.is_stopped() == false:
		game_timer.stop()

func _on_timer_timeout() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(RUTA_GAME_OVER)
