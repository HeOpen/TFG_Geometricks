extends StaticBody3D

@export var tiempo_fundido: float = 0.4
@export var volumen_cubo_db: float = -6.0

var texto_interfaz: String = "Inspeccionar Cubo [R]"
var en_proceso: bool = false

var _ventana: CanvasLayer = null
var _raiz: Control = null
var _player_ref: Node = null

const CUBO_SCENE = preload("res://level/2d_cube/cubo.tscn")
const MUSICA_CUBO = preload("res://assets/audio/musica/dance-with-night-wind_sh.wav")
# Tamaño de la ventana en píxeles de juego (proyecto 320×240)
const VENTANA_W := 120
const VENTANA_H := 120

func interactuar() -> void:
	if en_proceso:
		return
	en_proceso = true
	texto_interfaz = ""
	_abrir_ventana()

func _abrir_ventana() -> void:
	_player_ref = get_tree().get_first_node_in_group("Player")
	if _player_ref:
		_player_ref.process_mode = Node.PROCESS_MODE_DISABLED
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	_ventana = CanvasLayer.new()
	_ventana.layer = 10

	# Nodo raíz Control para animar la opacidad del overlay completo
	_raiz = Control.new()
	_raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_raiz.modulate.a = 0.0
	_ventana.add_child(_raiz)

	# Oscurecer el fondo sin taparlo — el mundo 3D sigue renderizándose detrás
	var dimmer = ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(dimmer)

	# Marco blanco fino alrededor de la ventana
	var borde = ColorRect.new()
	borde.color = Color(0, 0, 0, 1.0)
	borde.anchor_left = 0.5
	borde.anchor_right = 0.5
	borde.anchor_top = 0.5
	borde.anchor_bottom = 0.5
	borde.offset_left  = -(VENTANA_W / 2.0 + 1)
	borde.offset_right =   VENTANA_W / 2.0 + 1
	borde.offset_top   = -(VENTANA_H / 2.0 + 1)
	borde.offset_bottom =  VENTANA_H / 2.0 + 1
	borde.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(borde)

	# Ventana centrada con el cubo dentro
	var contenedor = SubViewportContainer.new()
	contenedor.stretch = true
	contenedor.focus_mode = Control.FOCUS_ALL
	contenedor.anchor_left = 0.5
	contenedor.anchor_right = 0.5
	contenedor.anchor_top = 0.5
	contenedor.anchor_bottom = 0.5
	contenedor.offset_left  = -VENTANA_W / 2.0
	contenedor.offset_right =  VENTANA_W / 2.0
	contenedor.offset_top   = -VENTANA_H / 2.0
	contenedor.offset_bottom =  VENTANA_H / 2.0
	_raiz.add_child(contenedor)

	var subviewport = SubViewport.new()
	subviewport.own_world_3d = true
	subviewport.size = Vector2i(VENTANA_W, VENTANA_H)
	contenedor.add_child(subviewport)
	subviewport.add_child(CUBO_SCENE.instantiate())

	# Pista de cierre en la parte inferior de la pantalla
	var pista = Label.new()
	pista.text = "[ESC] Cerrar"
	pista.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pista.anchor_left = 0.0
	pista.anchor_right = 1.0
	pista.anchor_top = 1.0
	pista.anchor_bottom = 1.0
	pista.offset_top = -18
	pista.offset_bottom = 0
	pista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(pista)

	get_tree().root.add_child(_ventana)
	contenedor.grab_focus()
	MusicManager.reproducir_temporal(MUSICA_CUBO, volumen_cubo_db, tiempo_fundido)

	var tween = create_tween()
	tween.tween_property(_raiz, "modulate:a", 1.0, tiempo_fundido)

	set_process_input(true)

func _input(event: InputEvent) -> void:
	if _ventana and event.is_action_pressed("ui_cancel"):
		_cerrar_ventana()
		get_viewport().set_input_as_handled()

func _cerrar_ventana() -> void:
	set_process_input(false)

	# Ambos fades (música y visual) arrancan en paralelo
	MusicManager.restaurar_anterior(tiempo_fundido)

	if is_instance_valid(_raiz):
		var tween = create_tween()
		tween.tween_property(_raiz, "modulate:a", 0.0, tiempo_fundido)
		await tween.finished

	if is_instance_valid(_ventana):
		_ventana.queue_free()
	_ventana = null
	_raiz = null

	if is_instance_valid(_player_ref):
		_player_ref.process_mode = Node.PROCESS_MODE_INHERIT
	_player_ref = null

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	en_proceso = false
	texto_interfaz = "Inspeccionar Cubo [R]"
