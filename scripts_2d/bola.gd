extends CharacterBody2D

enum Forma { CIRCULO, CUADRADO, TRIANGULO, RECTANGULO }

const SPEED = 300.0
const RADIUS = 8.0
const LEVITATION_ACCEL = 150.0
const MAX_LEVITATION_SPEED = 250.0

var forma_actual: Forma = Forma.CIRCULO

@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D

var tex_circulo   := preload("res://assets/models_2d/bola.png")
var tex_cuadrado  := preload("res://assets/models_2d/cuadrado.png")
var tex_triangulo := preload("res://assets/models_2d/triangulo.png")
var tex_rectangulo := preload("res://assets/models_2d/rectangulo.png")

var shape_circulo   := CircleShape2D.new()
var shape_cuadrado  := RectangleShape2D.new()
var shape_triangulo := ConvexPolygonShape2D.new()
var shape_rectangulo := RectangleShape2D.new()

# Escala del sprite por forma — ajusta según el tamaño de tus imágenes
var escalas := {
	Forma.CIRCULO:    Vector2(0.02, 0.02),
	Forma.CUADRADO:   Vector2(0.05, 0.05),
	Forma.TRIANGULO:  Vector2(0.1, 0.1),
	Forma.RECTANGULO: Vector2(0.02, 0.02),
}

func _ready() -> void:
	shape_circulo.radius = RADIUS
	shape_cuadrado.size = Vector2(25.0, 25.0)
	shape_triangulo.points = PackedVector2Array([
		Vector2(0.0, -10.0), Vector2(10.0, 10.0), Vector2(-10.0, 10.0)
	])
	shape_rectangulo.size = Vector2(12.0, 25.0)

# Detecta cambio de forma y delega la física según la forma activa
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("cambiar_forma"):
		_cambiar_forma()

	match forma_actual:
		Forma.CIRCULO:    _fisica_circulo(delta)
		Forma.CUADRADO:   _fisica_cuadrado(delta)
		Forma.TRIANGULO:  _fisica_triangulo(delta)
		Forma.RECTANGULO: _fisica_rectangulo(delta)

	move_and_slide()

# Cicla a la siguiente forma y actualiza colisión y sprite
func _cambiar_forma() -> void:
	forma_actual = (forma_actual + 1) % 4 as Forma
	match forma_actual:
		Forma.CIRCULO:    collision.shape = shape_circulo;    sprite.texture = tex_circulo
		Forma.CUADRADO:   collision.shape = shape_cuadrado;   sprite.texture = tex_cuadrado
		Forma.TRIANGULO:  collision.shape = shape_triangulo;  sprite.texture = tex_triangulo
		Forma.RECTANGULO: collision.shape = shape_rectangulo; sprite.texture = tex_rectangulo
	sprite.scale = escalas[forma_actual]
	sprite.rotation = 0.0

# Círculo: gravedad normal, rotación visual al moverse
func _fisica_circulo(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0.0, SPEED)
	sprite.rotation += velocity.x / RADIUS * delta

# Cuadrado: solo cae por gravedad, no se puede mover horizontalmente
func _fisica_cuadrado(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = 0.0

# Triángulo: sube progresivamente solo, sin control horizontal
func _fisica_triangulo(delta: float) -> void:
	velocity.y = move_toward(velocity.y, -MAX_LEVITATION_SPEED, LEVITATION_ACCEL * delta)
	velocity.x = 0.0

# Rectángulo: sin gravedad, solo movimiento horizontal
func _fisica_rectangulo(_delta: float) -> void:
	velocity.y = move_toward(velocity.y, 0.0, SPEED)
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0.0, SPEED)
