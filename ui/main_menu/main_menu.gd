extends Node3D

@onready var cubo = $CuboMilenario

# Definimos las rotaciones absolutas en radianes para cada cara
const ANGULO_FRONTAL = 0.0
const ANGULO_DERECHA = deg_to_rad(-90)
const ANGULO_TRASERA = deg_to_rad(-180)
const ANGULO_IZQUIERDA = deg_to_rad(90)

func _ready():
	# Asumimos que conectaste las señales de todos los botones a esta función desde el editor
	pass

func _on_boton_presionado(nombre_del_boton: String):
	# La variable 'nombre_del_boton' viene directamente de tu @export var texto_boton
	match nombre_del_boton:
		# --- NAVEGACIÓN ---
		"OPCIONES":
			_rotar_cubo_hacia(ANGULO_DERECHA)
		"AUDIO":
			_rotar_cubo_hacia(ANGULO_TRASERA)
		"VIDEO":
			_rotar_cubo_hacia(ANGULO_IZQUIERDA)
		"VOLVER":
			# Si estamos en Audio o Video, volvemos al submenú Opciones (Derecha)
			# Necesitamos lógica condicional basada en la rotación actual
			if is_equal_approx(cubo.rotation.y, ANGULO_TRASERA) or is_equal_approx(cubo.rotation.y, ANGULO_IZQUIERDA):
				_rotar_cubo_hacia(ANGULO_DERECHA)
			else:
				_rotar_cubo_hacia(ANGULO_FRONTAL) # Volvemos al Main Menu
		
		# --- EJECUCIÓN DE ACCIONES ---
		"JUGAR":
			print("Iniciando secuencia de carga...")
		"SALIR":
			get_tree().quit()
			
		# --- AJUSTES CÍCLICOS ---
		"VHS: ON", "VHS: OFF":
			_alternar_vhs()

func _rotar_cubo_hacia(angulo_destino_y: float):
	# Matamos cualquier tween previo para evitar bugs si el jugador hace doble clic rápido
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Rotamos la propiedad 'rotation:y' al nuevo ángulo absoluto en 0.6 segundos
	tween.tween_property(cubo, "rotation:y", angulo_destino_y, 0.6)

func _alternar_vhs():
	# Aquí buscas el botón y le cambias el texto, además de activar/desactivar tu CanvasLayer
	pass
