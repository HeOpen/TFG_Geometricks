extends AnimatableBody2D

# Puedes cambiar estos valores directamente desde el Inspector de cada plataforma
@export var movimiento: Vector2 = Vector2(300, 0) # Por defecto, se mueve 300px a la derecha
@export var duracion: float = 3.0                # Tiempo en segundos que tarda en ir

func _ready():
	var pos_inicial = position
	var pos_final = pos_inicial + movimiento
	
	# Creamos un bucle de movimiento infinito (Ping-Pong)
	var tween = create_tween().set_loops()
	
	# Ida hacia la posición final
	tween.tween_property(self, "position", pos_final, duracion)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
	# Vuelta a la posición inicial
	tween.tween_property(self, "position", pos_inicial, duracion)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
