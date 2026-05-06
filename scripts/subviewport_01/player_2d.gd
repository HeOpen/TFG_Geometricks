extends CharacterBody2D

# --- PARÁMETROS (editables desde el Inspector de Godot) ---

# Velocidad de desplazamiento horizontal en píxeles por segundo
@export var velocidad: float = 300.0

# Fuerza del salto: cuanto mayor, más alto salta
@export var fuerza_salto: float = 600.0

# Intensidad de la gravedad: cuanto mayor, más rápido cae
@export var gravedad: float = 1200.0

func _physics_process(delta):

	# --- GRAVEDAD ---
	# Si el jugador no está pisando nada, acumulamos velocidad hacia abajo.
	# En 2D, y positivo = hacia abajo en pantalla, de ahí que sumemos.
	if not is_on_floor():
		velocity.y += gravedad * delta

	# --- SALTO ---
	# Solo puede saltar si está en el suelo (is_on_floor lo detecta
	# comparando la normal de la superficie con up_direction).
	# La velocidad negativa en Y lanza al jugador hacia arriba.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -fuerza_salto

	# --- MOVIMIENTO HORIZONTAL ---
	# get_axis devuelve: -1 (izquierda), 0 (parado), 1 (derecha)
	var dir_x = Input.get_axis("ui_left", "ui_right")
	velocity.x = dir_x * velocidad

	# --- APLICAR MOVIMIENTO Y COLISIONES ---
	# move_and_slide mueve el cuerpo y resuelve colisiones con StaticBody2D.
	# Usa la propiedad up_direction (por defecto Vector2.UP = hacia arriba)
	# para saber qué superficies cuentan como "suelo".
	move_and_slide()
