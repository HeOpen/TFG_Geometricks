extends Node3D

const VIEWPORT_SIZE := 512.0
const TRANSITION_DURATION := 0.8
const CAMERA_RADIUS := 2.0
const ENTRY_OFFSET := 50.0

# Orden de caras girando a la derecha: z0 → x0 → z1 → x1 → z0
const ADJACENCY: Dictionary = {
	"Cara_z0": {"right": "Cara_x0", "left": "Cara_x1"},
	"Cara_x0": {"right": "Cara_z1", "left": "Cara_z0"},
	"Cara_z1": {"right": "Cara_x1", "left": "Cara_x0"},
	"Cara_x1": {"right": "Cara_z0", "left": "Cara_z1"},
}

var _camera: Camera3D
var _is_transitioning := false
var _current_angle := 0.0
var _face_nodes: Dictionary = {}

func _ready() -> void:
	_camera = $Camera3D
	_face_nodes = {
		"Cara_z0": $Cara_z0/SubViewport_z0/Cara_z0,
		"Cara_x0": $Cara_x0/SubViewport_x0/Cara_x0,
		"Cara_z1": $Cara_z1/SubViewport_z1/Cara_z1,
		"Cara_x1": $Cara_x1/SubViewport_x1/Cara_x1,
	}
	for face_name in _face_nodes:
		_face_nodes[face_name].player_exiting.connect(
			_on_player_exiting.bind(face_name)
		)

func _on_player_exiting(side: String, player_y: float, player_vel: Vector2, from_name: String) -> void:
	if _is_transitioning:
		return
	var to_name: String = ADJACENCY[from_name][side]
	_do_transition(from_name, to_name, side, player_y, player_vel)

func _do_transition(from_name: String, to_name: String, side: String, py: float, vel: Vector2) -> void:
	_is_transitioning = true

	var from_face: Node2D = _face_nodes[from_name]
	var to_face: Node2D = _face_nodes[to_name]

	var player: CharacterBody2D = from_face.get_node_or_null("bola_2d")
	if player == null:
		_is_transitioning = false
		return

	# Reubica el jugador en la cara destino antes de cualquier físicas
	var entry_x := ENTRY_OFFSET if side == "right" else VIEWPORT_SIZE - ENTRY_OFFSET
	player.reparent(to_face, false)          # false: no conservar transform global entre SubViewports
	player.position = Vector2(entry_x, py)
	player.velocity = Vector2(vel.x, vel.y)

	# Ángulo de rotación de cámara: +90° al ir derecha, -90° al ir izquierda
	var delta_angle := PI * 0.5 if side == "right" else -PI * 0.5
	var end_angle := _current_angle + delta_angle

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_update_camera, _current_angle, end_angle, TRANSITION_DURATION)
	tween.tween_callback(_on_transition_done)

func _update_camera(angle: float) -> void:
	_current_angle = angle
	_camera.position = Vector3(CAMERA_RADIUS * sin(angle), 0.0, CAMERA_RADIUS * cos(angle))
	_camera.look_at(Vector3.ZERO, Vector3.UP)

func _on_transition_done() -> void:
	_is_transitioning = false
