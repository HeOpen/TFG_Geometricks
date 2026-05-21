extends CharacterBody2D

@export var velocidad_caminar: float = 300.0
@export var fuerza_salto: float = -250.0 
@export var velocidad_escalar: float = 200.0 

# Lista (Array) para poder asignar todas las capas de las caras en el Inspector
@export var mapas_tiles: Array[TileMapLayer] 
@export var nodo_lava: Node2D # Enlace a la escena de la lava activa

var gravedad: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var esta_escalando: bool = false
var posicion_spawn: Vector2

func _ready():
	# Al iniciar el juego, guardamos la posición inicial como el primer spawn
	posicion_spawn = global_position

func _physics_process(delta: float):
	var en_zona_escalable = false
	var en_zona_daño = false
	
	# --- 1. DETECTAR BALDOSAS EN TODOS LOS MAPAS ---
	for mapa in mapas_tiles:
		if mapa == null: continue 
		
		# Comprobación de Árbol/Escalera (Centro del cuerpo)
		var punto_cuerpo = global_position + Vector2(0, -20)
		var tile_coords_cuerpo = mapa.local_to_map(mapa.to_local(punto_cuerpo))
		var tile_data_cuerpo = mapa.get_cell_tile_data(tile_coords_cuerpo)
		
		if tile_data_cuerpo and tile_data_cuerpo.get_custom_data("escalable"):
			en_zona_escalable = true

		# Comprobación de Pinchos por Posición (Pies)
		var punto_pies = global_position
		var tile_coords_pies = mapa.local_to_map(mapa.to_local(punto_pies))
		var tile_data_pies = mapa.get_cell_tile_data(tile_coords_pies)
		
		if tile_data_pies and tile_data_pies.get_custom_data("pincho"):
			en_zona_daño = true

	# --- 2. LÓGICA DE MOVIMIENTO VERTICAL (Y) ---
	if en_zona_escalable:
		if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
			esta_escalando = true 
			var dir_escalar = Input.get_axis("ui_up", "ui_down")
			velocity.y = dir_escalar * velocidad_escalar
		elif esta_escalando:
			velocity.y = 0 # Mantenerse colgado estático si no se pulsa arriba/abajo
		else:
			_aplicar_gravedad_y_salto(delta)
	else:
		esta_escalando = false
		_aplicar_gravedad_y_salto(delta)

	# --- 3. LÓGICA DE MOVIMIENTO HORIZONTAL (X) ---
	# Al estar fuera de las condiciones verticales, permite salir lateralmente a mitad de camino
	var direccion_x = Input.get_axis("ui_left", "ui_right")
	if direccion_x != 0:
		velocity.x = direccion_x * velocidad_caminar
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad_caminar)

	# --- 4. EJECUTAR MOVIMIENTO FÍSICO ---
	move_and_slide()

	# --- 5. DETECTAR PINCHOS POR IMPACTO SÓLIDO ---
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var colisionador = colision.get_collider()
		
		if colisionador is TileMapLayer and colisionador in mapas_tiles:
			var coords_baldosa = colisionador.get_coords_for_body_rid(colision.get_collider_rid())
			var tile_data_choque = colisionador.get_cell_tile_data(coords_baldosa)
			
			if tile_data_choque and tile_data_choque.get_custom_data("pincho"):
				en_zona_daño = true

	# --- 6. COMPROBAR CONDICIÓN DE MUERTE ---
	if en_zona_daño:
		morir_y_reaparecer()

func _aplicar_gravedad_y_salto(delta: float):
	if not is_on_floor():
		velocity.y += gravedad * delta

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = fuerza_salto

func morir_y_reaparecer():
	global_position = posicion_spawn
	velocity = Vector2.ZERO
	esta_escalando = false
	
	if nodo_lava and nodo_lava.has_method("resetear"):
		nodo_lava.resetear()

func actualizar_punto_control(nueva_posicion: Vector2):
	posicion_spawn = nueva_posicion
