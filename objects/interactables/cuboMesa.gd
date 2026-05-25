extends StaticBody3D

@export_file("*.tscn") var escena_destino: String = "res://level/2d_cube/cubo.tscn"
@export var tiempo_zoom: float = 1.4
@export var tiempo_fundido: float = 0.5

# Variables obligatorias para que el sistema de tu compañero reconozca el objeto
var texto_interfaz: String = "Inspeccionar Cubo [R]"
var en_proceso: bool = false

# Esta es la función que el script de tu Player va a llamar al pulsar el botón
func interactuar() -> void:
	# Si ya estamos en medio de la cinemática, ignoramos nuevos clics
	if en_proceso:
		return
		
	en_proceso = true
	texto_interfaz = "" # Ocultamos el texto de la pantalla
	
	var camara = get_viewport().get_camera_3d()
	if not camara:
		_saltar_a_escena()
		return
		
	# 1. Animación de Zoom y acercamiento
	var tween_cine = create_tween().set_parallel(true)
	tween_cine.set_ease(Tween.EASE_IN_OUT)
	tween_cine.set_trans(Tween.TRANS_CUBIC)
	
	tween_cine.tween_property(camara, "fov", 18.0, tiempo_zoom)
	
	var posicion_cercana = camara.global_position.move_toward(global_position, camara.global_position.distance_to(global_position) * 0.4)
	tween_cine.tween_property(camara, "global_position", posicion_cercana, tiempo_zoom)
	
	await tween_cine.finished
	
	# 2. Fundido a negro
	var capa_interfaz = CanvasLayer.new()
	var rectangulo_negro = ColorRect.new()
	rectangulo_negro.color = Color(0, 0, 0, 0)
	rectangulo_negro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	capa_interfaz.add_child(rectangulo_negro)
	add_child(capa_interfaz)
	
	var tween_fundido = create_tween()
	tween_fundido.tween_property(rectangulo_negro, "color:a", 1.0, tiempo_fundido)
	
	await tween_fundido.finished
	
	# 3. Cambio de escena
	_saltar_a_escena()

func _saltar_a_escena() -> void:
	if ResourceLoader.exists(escena_destino):
		get_tree().change_scene_to_file(escena_destino)
	else:
		print("Error crítico: No se encuentra la escena del cubo 2D en: ", escena_destino)
		# Si falla, reiniciamos el estado para poder volver a intentarlo
		en_proceso = false
		texto_interfaz = "Inspeccionar Cubo [R]"
