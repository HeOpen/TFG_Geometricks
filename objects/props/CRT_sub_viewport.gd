extends SubViewport

# Obtenemos la referencia directa al reproductor de vídeo hijo
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	# 1. Forzamos dimensiones explícitas en memoria antes de renderizar
	size = Vector2(960, 720) 
	
	# 2. Detenemos cualquier intento de reproducción automática del editor
	video_player.stop()
	
	# 3. Esperamos un fotograma inactivo para asegurar que el entorno 3D esté cargado
	await get_tree().process_frame
	
	# 4. Iniciamos el vídeo de forma segura
	video_player.play()
