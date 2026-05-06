extends Node2D

@onready var player = $Player2D
@onready var camara = $Camera2D
@onready var cubo_3d = get_node_or_null("../../Node3D")

var ancho_cara = 1152
var alto_cara = 648
var cuadricula_camara = Vector2(0, 0)

var origen_amarilla_nx = 0
var origen_naranja_nx = 0
var pos_anterior = Vector2.ZERO

func _ready():
	camara.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
	pos_anterior = player.position
	actualizar_posicion_y_cubo(0)

func cara_opuesta(nx: int) -> int:
	if nx == 0:  return 2
	if nx == 1:  return -1
	if nx == -1: return 1
	if nx == 2:  return 0
	return 0

func _process(_delta):
	var hizo_teleport = false

	var nx_ant = floor(pos_anterior.x / ancho_cara)
	var ny_ant = floor(pos_anterior.y / alto_cara)
	var pos = player.position

	# --- ECUADOR (cara1, cara2, cara3, cara4) ---
	if ny_ant == 0:
		if pos.y < 0:
			origen_amarilla_nx = nx_ant
			player.position.x = ancho_cara / 2
			player.position.y = -20
			hizo_teleport = true
		elif pos.y > alto_cara:
			origen_naranja_nx = nx_ant
			player.position.x = ancho_cara / 2
			player.position.y = alto_cara + 20
			hizo_teleport = true
		elif pos.x >= ancho_cara * 3:
			player.position.x = -ancho_cara + 20
			hizo_teleport = true
		elif pos.x < -ancho_cara:
			player.position.x = (ancho_cara * 3) - 20
			hizo_teleport = true

	# --- CARA SUPERIOR (cara5) ---
	elif ny_ant == -1:
		if pos.y > 0:
			player.position.x = (origen_amarilla_nx * ancho_cara) + (ancho_cara / 2)
			player.position.y = 20
			hizo_teleport = true
		elif pos.y < -alto_cara:
			var opuesto = cara_opuesta(origen_amarilla_nx)
			player.position.x = (opuesto * ancho_cara) + (ancho_cara / 2)
			player.position.y = alto_cara - 20
			hizo_teleport = true
		elif pos.x >= ancho_cara:
			player.position.x = ancho_cara + 20
			player.position.y = alto_cara / 2
			hizo_teleport = true
		elif pos.x < 0:
			player.position.x = -20
			player.position.y = alto_cara / 2
			hizo_teleport = true

	# --- CARA INFERIOR (cara6) ---
	elif ny_ant == 1:
		if pos.y < alto_cara:
			player.position.x = (origen_naranja_nx * ancho_cara) + (ancho_cara / 2)
			player.position.y = alto_cara - 20
			hizo_teleport = true
		elif pos.y > alto_cara * 2:
			var opuesto = cara_opuesta(origen_naranja_nx)
			player.position.x = (opuesto * ancho_cara) + (ancho_cara / 2)
			player.position.y = 20
			hizo_teleport = true
		elif pos.x >= ancho_cara:
			player.position.x = ancho_cara + 20
			player.position.y = alto_cara / 2
			hizo_teleport = true
		elif pos.x < 0:
			player.position.x = -20
			player.position.y = alto_cara / 2
			hizo_teleport = true

	if hizo_teleport:
		camara.position += player.position - pos_anterior

	pos_anterior = player.position

	var nx_actual = floor(player.position.x / ancho_cara)
	var ny_actual = floor(player.position.y / alto_cara)

	if nx_actual != cuadricula_camara.x or ny_actual != cuadricula_camara.y:
		cuadricula_camara = Vector2(nx_actual, ny_actual)
		actualizar_posicion_y_cubo(0.4)

func actualizar_posicion_y_cubo(duracion):
	var centro_x = (cuadricula_camara.x * ancho_cara) + (ancho_cara / 2)
	var centro_y = (cuadricula_camara.y * alto_cara) + (alto_cara / 2)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(camara, "position:x", centro_x, duracion) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camara, "position:y", centro_y, duracion) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var id_cara = obtener_nombre_cara(cuadricula_camara)
	if cubo_3d and cubo_3d.has_method("girar_a_cara"):
		cubo_3d.girar_a_cara(id_cara)

func obtener_nombre_cara(coord: Vector2) -> String:
	var x = int(coord.x)
	var y = int(coord.y)
	if y == -1: return "cara5"
	if y == 1:  return "cara6"
	if x == 0:  return "cara1"
	if x == 1:  return "cara2"
	if x == -1: return "cara3"
	if x == 2:  return "cara4"
	return "cara1"
