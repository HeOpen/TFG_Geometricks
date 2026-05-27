extends Node3D

# --- Referencias Expuestas ---
# Asigna estos nodos desde el panel Inspector del editor
@export var audio_noticias: AudioStreamPlayer3D
@export var cinta_vhs: StaticBody3D

func _ready() -> void:
	# 1. Fase de Preparación Cero
	_ocultar_cinta_inicialmente()
	
	# 2. Arranque de la máquina de estados temporal
	_iniciar_secuencia()

func _ocultar_cinta_inicialmente() -> void:
	if cinta_vhs:
		# Hacemos la malla invisible
		cinta_vhs.visible = false
		# Desactivamos el procesamiento físico y lógico. 
		# Esto asegura que el RayCast3D del jugador ignore el objeto por completo.
		cinta_vhs.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		push_error("Error: Nodo cinta_vhs no asignado en GestorIntro.")

func _iniciar_secuencia() -> void:
	# Retención 1: Silencio inicial
	await get_tree().create_timer(5.0).timeout
	
	if audio_noticias:
		audio_noticias.play()
	
	# Retención 2: Transmisión de las noticias
	await get_tree().create_timer(50.0).timeout
	
	_manifestar_cinta_vhs()

func _manifestar_cinta_vhs() -> void:
	if cinta_vhs:
		# Restauramos la visibilidad
		cinta_vhs.visible = true
		# Devolvemos el estado de colisiones a la normalidad heredada
		cinta_vhs.process_mode = Node.PROCESS_MODE_INHERIT
