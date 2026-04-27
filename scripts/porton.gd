extends Node3D

@export var altura_subida: float = 4.0
@export var tween_duration: float = 0.6

var _barrotes: Array[Node3D] = []
var _posiciones_originales: Array[float] = []
var _abierto: bool = false

func _ready() -> void:
	for node in find_children("*Barrote*", "", true, false):
		_barrotes.append(node)
		_posiciones_originales.append(node.position.y)

func abrir() -> void:
	if _abierto:
		return
	_abierto = true
	for i in range(_barrotes.size()):
		var tween = create_tween()
		tween.tween_property(_barrotes[i], "position:y", _posiciones_originales[i] + altura_subida, tween_duration)

func cerrar() -> void:
	if not _abierto:
		return
	_abierto = false
	for i in range(_barrotes.size()):
		var tween = create_tween()
		tween.tween_property(_barrotes[i], "position:y", _posiciones_originales[i], tween_duration)
