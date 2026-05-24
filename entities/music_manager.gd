extends Node

# --- Referencias a Nodos ---
@onready var audio_player: AudioStreamPlayer = $AudioPlayer

# --- Definición de Estados del Sistema ---
# Un enum (enumerado) asigna un valor numérico secuencial e inmutable a palabras clave.
# MENU = 0, INTRO = 1, JUEGO = 2, FINAL = 3. Esto evita errores de escritura de texto.
enum EstadosMusica { MENU, INTRO, JUEGO, FINAL }
var estado_actual: EstadosMusica = EstadosMusica.MENU

# --- Recursos de Audio (@export) ---
# Al usar Array[AudioStream], forzamos al Inspector a aceptar únicamente archivos de sonido (.ogg/.wav).
@export var tema_menu: AudioStream
@export var tema_intro: AudioStream
@export var lista_ambiente: Array[AudioStream] = []
@export var tema_final: AudioStream

# --- Variables de Control Interno ---
var indice_pista_actual: int = 0

func _ready() -> void:
	# Conectamos la señal nativa 'finished'. Godot la emite automáticamente 
	# cuando una canción llega al último milisegundo de su reproducción.
	audio_player.finished.connect(_on_audio_player_finished)

# --- Métodos Públicos de Control de Estado ---

func reproducir_menu() -> void:
	estado_actual = EstadosMusica.MENU
	audio_player.stream = tema_menu
	audio_player.play()

func reproducir_intro() -> void:
	estado_actual = EstadosMusica.INTRO
	audio_player.stream = tema_intro
	audio_player.play()

func iniciar_playlist_juego() -> void:
	estado_actual = EstadosMusica.JUEGO
	# Validamos que el arreglo contenga archivos para evitar divisiones por cero o desbordamientos.
	if lista_ambiente.size() > 0:
		indice_pista_actual = 0
		_reproducir_pista_ambiente(indice_pista_actual)
	else:
		push_error("Error: La lista de ambiente está vacía en MusicManager.")

func reproducir_final() -> void:
	estado_actual = EstadosMusica.FINAL
	audio_player.stream = tema_final
	audio_player.play()

# --- Métodos Privados de Lógica Interno ---

func _reproducir_pista_ambiente(indice: int) -> void:
	# Asignamos el archivo de audio correspondiente al índice del arreglo
	audio_player.stream = lista_ambiente[indice]
	audio_player.play()

func _on_audio_player_finished() -> void:
	# Evaluamos el estado actual. Si estamos en MENU, INTRO o FINAL, 
	# las canciones individuales simplemente se repiten en bucle (loop).
	if estado_actual != EstadosMusica.JUEGO:
		audio_player.play()
		return
		
	# Lógica específica para la lista de reproducción de 5 canciones:
	# 1. Incrementamos el índice para pasar a la siguiente canción del arreglo.
	indice_pista_actual += 1
	
	# 2. Operación Matemática del Módulo (%):
	# Si indice_pista_actual llega a 5 y el tamaño del arreglo es 5, 5 % 5 devuelve 0.
	# Esto reinicia el contador al principio de la lista automáticamente, creando un bucle infinito.
	indice_pista_actual = indice_pista_actual % lista_ambiente.size()
	
	# 3. Reproducimos el siguiente tema cargado en memoria.
	_reproducir_pista_ambiente(indice_pista_actual)
