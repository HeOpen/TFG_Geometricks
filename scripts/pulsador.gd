extends Node3D

@export var tween_duration: float = 0.15
@export var porton: Node3D

@onready var area: Area3D = $Area3D

var _original_scale_y: float
var _bodies: Array = []
var _pressed: bool = false

func _ready() -> void:
	_original_scale_y = scale.y
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	var should_press = false
	for body in _bodies:
		if is_instance_valid(body) and body.get("forma_actual") == 1:  # Forma.CUBO
			should_press = true
			break

	if should_press and not _pressed:
		_press()
	elif not should_press and _pressed:
		_release()

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("_aplicar_forma"):
		_bodies.append(body)

func _on_body_exited(body: Node3D) -> void:
	_bodies.erase(body)

func _press() -> void:
	_pressed = true
	var tween = create_tween()
	tween.tween_property(self, "scale:y", _original_scale_y * 0.4, tween_duration)
	if porton:
		porton.abrir()

func _release() -> void:
	_pressed = false
	var tween = create_tween()
	tween.tween_property(self, "scale:y", _original_scale_y, tween_duration)
	if porton:
		porton.cerrar()
