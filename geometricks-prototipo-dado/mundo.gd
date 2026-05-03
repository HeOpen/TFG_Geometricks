extends Node2D

@onready var player = $Player2D
@onready var camara = $Camera2D
@onready var cubo_3d = get_node_or_null("../../Node3D") 

var ancho_cara = 1152
var alto_cara = 648
var cuadrícula_camara = Vector2(0, 0)

# --- MEMORIA DEL MAPA ---
var origen_amarilla_nx = 0 # Guarda de qué cara subiste a la Amarilla (0=Verde, 1=Roja, etc)
var origen_naranja_nx = 0  # Guarda de qué cara bajaste a la Naranja
var pos_anterior = Vector2.ZERO 

func _ready():
	camara.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
	pos_anterior = player.position
	actualizar_posicion_y_cubo(0)

# Función mágica para saber qué cara está enfrente de la otra
func cara_opuesta(nx: int) -> int:
	if nx == 0: return 2   # Verde -> Rosa
	if nx == 1: return -1  # Roja -> Azul
	if nx == -1: return 1  # Azul -> Roja
	if nx == 2: return 0   # Rosa -> Verde
	return 0

func _process(_delta):
	var hizo_teleport = false
	
	# Usamos la posición del frame anterior para saber en qué cara estábamos con seguridad
	var nx_ant = floor(pos_anterior.x / ancho_cara)
	var ny_ant = floor(pos_anterior.y / alto_cara)
	var pos = player.position

	# ==========================================
	# 1. ESTAMOS EN EL ECUADOR (Verde, Roja, Azul, Rosa)
	# ==========================================
	if ny_ant == 0:
		# A. SUBIR -> Entrar a la Amarilla (Por la parte de abajo)
		if pos.y < 0: 
			origen_amarilla_nx = nx_ant
			player.position.x = ancho_cara / 2
			player.position.y = -20
			hizo_teleport = true
			
		# B. BAJAR -> Entrar a la Naranja (Por la parte de arriba)
		elif pos.y > alto_cara: 
			origen_naranja_nx = nx_ant
			player.position.x = ancho_cara / 2
			player.position.y = alto_cara + 20
			hizo_teleport = true
			
		# C. BUCLE HORIZONTAL (Rosa <-> Azul)
		elif pos.x >= ancho_cara * 3: # Salir de Rosa por derecha
			player.position.x = -ancho_cara + 20
			hizo_teleport = true
		elif pos.x < -ancho_cara: # Salir de Azul por izquierda
			player.position.x = (ancho_cara * 3) - 20
			hizo_teleport = true

	# ==========================================
	# 2. ESTAMOS EN LA CARA AMARILLA (Tapa Superior)
	# ==========================================
	elif ny_ant == -1:
		# A. VOLVER ATRÁS (Bajar -> Volver a la cara origen)
		if pos.y > 0:
			player.position.x = (origen_amarilla_nx * ancho_cara) + (ancho_cara / 2)
			player.position.y = 20 # Entras por arriba de la cara
			hizo_teleport = true
			
		# B. CRUZAR EL CUBO (Subir -> Ir a la cara opuesta)
		elif pos.y < -alto_cara:
			var opuesto = cara_opuesta(origen_amarilla_nx)
			player.position.x = (opuesto * ancho_cara) + (ancho_cara / 2)
			player.position.y = alto_cara - 20 # Entras por ABAJO de la cara opuesta
			hizo_teleport = true
			
		# C. SALIDAS LATERALES EN LA AMARILLA
		elif pos.x >= ancho_cara: # Derecha -> Roja Izquierda
			player.position.x = ancho_cara + 20
			player.position.y = alto_cara / 2
			hizo_teleport = true
		elif pos.x < 0: # Izquierda -> Azul Derecha
			player.position.x = -20
			player.position.y = alto_cara / 2
			hizo_teleport = true

	# ==========================================
	# 3. ESTAMOS EN LA CARA NARANJA (Tapa Inferior)
	# ==========================================
	elif ny_ant == 1:
		# A. VOLVER ATRÁS (Subir -> Volver a la cara origen)
		if pos.y < alto_cara:
			player.position.x = (origen_naranja_nx * ancho_cara) + (ancho_cara / 2)
			player.position.y = alto_cara - 20 # Entras por abajo de la cara
			hizo_teleport = true
			
		# B. CRUZAR EL CUBO (Bajar -> Ir a la cara opuesta)
		elif pos.y > alto_cara * 2:
			var opuesto = cara_opuesta(origen_naranja_nx)
			player.position.x = (opuesto * ancho_cara) + (ancho_cara / 2)
			player.position.y = 20 # Entras por ARRIBA de la cara opuesta
			hizo_teleport = true
			
		# C. SALIDAS LATERALES EN LA NARANJA
		elif pos.x >= ancho_cara: # Derecha -> Roja Izquierda
			player.position.x = ancho_cara + 20
			player.position.y = alto_cara / 2
			hizo_teleport = true
		elif pos.x < 0: # Izquierda -> Azul Derecha
			player.position.x = -20
			player.position.y = alto_cara / 2
			hizo_teleport = true

	# ==========================================
	# 4. FLUIDEZ DE CÁMARA Y ACTUALIZACIÓN
	# ==========================================
	if hizo_teleport:
		var diferencia = player.position - pos_anterior
		camara.position += diferencia # Salto de cámara invisible
		
	# Guardamos la posición actual para el frame que viene
	pos_anterior = player.position

	var nx_actual = floor(player.position.x / ancho_cara)
	var ny_actual = floor(player.position.y / alto_cara)

	if nx_actual != cuadrícula_camara.x or ny_actual != cuadrícula_camara.y:
		cuadrícula_camara = Vector2(nx_actual, ny_actual)
		actualizar_posicion_y_cubo(0.4)

func actualizar_posicion_y_cubo(duracion):
	var centro_x = (cuadrícula_camara.x * ancho_cara) + (ancho_cara / 2)
	var centro_y = (cuadrícula_camara.y * alto_cara) + (alto_cara / 2)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camara, "position:x", centro_x, duracion).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(camara, "position:y", centro_y, duracion).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	var id_cara = obtener_nombre_cara(cuadrícula_camara)
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
