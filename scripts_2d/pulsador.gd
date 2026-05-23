extends Area2D

# Arrastra aquí el nodo Bloque que debe desaparecer al activarse
@export var bloque: AnimatableBody2D

var _activada := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

# Se activa solo una vez cuando el cuadrado pisa la plataforma
func _on_body_entered(body: Node2D) -> void:
	if _activada:
		return
	if body is CharacterBody2D and body.forma_actual == body.Forma.CUADRADO:
		_activada = true
		bloque.desaparecer()
