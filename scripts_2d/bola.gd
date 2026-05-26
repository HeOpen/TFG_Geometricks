extends CharacterBody2D

enum Forma { CIRCULO, CUADRADO, TRIANGULO, RECTANGULO }

const SPEED = 120.0
const JUMP_VELOCITY = -300.0
const RADIUS = 6.0
const LEVITATION_ACCEL = 200.0
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

var escalas := {
	Forma.CIRCULO:    Vector2(0.02, 0.02),
	Forma.CUADRADO:   Vector2(0.05, 0.05),
	Forma.TRIANGULO:  Vector2(0.1, 0.1),
	Forma.RECTANGULO: Vector2(0.02, 0.02),
}

# Mapeo de teclas (1-4) → (forma, id de ítem requerido)
const TECLAS_FORMA := [
	["forma_1", Forma.CIRCULO,    "canica_bola"],
	["forma_2", Forma.CUADRADO,   "cuadrado_rubik"],
	["forma_3", Forma.TRIANGULO,  "piramide_illuminati"],
	["forma_4", Forma.RECTANGULO, "rectangulo_memorycard"],
]

func _ready() -> void:
	shape_circulo.radius = RADIUS
	shape_cuadrado.size = Vector2(10.0, 10.0)
	shape_triangulo.points = PackedVector2Array([
		Vector2(0.0, -5.0), Vector2(5.0, 5.0), Vector2(-5.0, 5.0)
	])
	shape_rectangulo.size = Vector2(5.0, 10.0)

func _physics_process(delta: float) -> void:
	for entry in TECLAS_FORMA:
		if Input.is_action_just_pressed(entry[0]) and InventoryManager.tiene_item(entry[2]):
			_aplicar_forma(entry[1])
			break

	match forma_actual:
		Forma.CIRCULO:    _fisica_circulo(delta)
		Forma.CUADRADO:   _fisica_cuadrado(delta)
		Forma.TRIANGULO:  _fisica_triangulo(delta)
		Forma.RECTANGULO: _fisica_rectangulo(delta)

	move_and_slide()

func _aplicar_forma(nueva_forma: Forma) -> void:
	if forma_actual == nueva_forma:
		return
	forma_actual = nueva_forma
	match forma_actual:
		Forma.CIRCULO:    collision.shape = shape_circulo;    sprite.texture = tex_circulo
		Forma.CUADRADO:   collision.shape = shape_cuadrado;   sprite.texture = tex_cuadrado
		Forma.TRIANGULO:  collision.shape = shape_triangulo;  sprite.texture = tex_triangulo
		Forma.RECTANGULO: collision.shape = shape_rectangulo; sprite.texture = tex_rectangulo
	sprite.scale = escalas[forma_actual]
	sprite.rotation = 0.0

func _fisica_circulo(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0.0, SPEED)
	sprite.rotation += velocity.x / RADIUS * delta

func _fisica_cuadrado(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = 0.0

func _fisica_triangulo(delta: float) -> void:
	velocity.y = move_toward(velocity.y, -MAX_LEVITATION_SPEED, LEVITATION_ACCEL * delta)
	velocity.x = 0.0

func _fisica_rectangulo(_delta: float) -> void:
	velocity.y = move_toward(velocity.y, 0.0, SPEED)
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0.0, SPEED)
