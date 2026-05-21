extends Area2D

@export var velocidad_subida: float = 15.0 
@export var tiempo_espera: float = 3.0 # NUEVO: Segundos de retraso antes de subir

var posicion_inicial: Vector2
var temporizador: float = 0.0 # NUEVO: Cronómetro interno

func _ready():
	posicion_inicial = position
	# Al arrancar, llenamos el cronómetro con los 3 segundos
	temporizador = tiempo_espera

func _process(delta: float):
	# Si el cronómetro aún tiene tiempo, lo vamos restando
	if temporizador > 0:
		temporizador -= delta
	else:
		# Si el cronómetro llega a 0 (o menos), la lava empieza a subir
		position.y -= velocidad_subida * delta

func _on_body_entered(body: Node2D):
	if body.has_method("morir_y_reaparecer"):
		body.morir_y_reaparecer()

func resetear():
	# Al morir, devolvemos la lava abajo y REINICIAMOS el cronómetro a 3 segundos
	position = posicion_inicial
	temporizador = tiempo_espera
