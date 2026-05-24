extends Node3D

const VIEWPORT_SIZE := 512.0
const TRANSITION_DURATION := 0.8
const CAMERA_RADIUS := 2.0
const ENTRY_OFFSET := 50.0

# Adyacencia geométrica correcta basada en orientación de viewports:
# y0 = cara superior (normal +Y, cámara desde arriba): right=-Z, down=+X → bottom=x0, top=x1, left=z0, right=z1
# y1 = cara inferior (normal -Y, cámara desde abajo): right=-Z, down=-X → top=x0, bottom=x1, left=z0, right=z1
const ADJACENCY: Dictionary = {
	"Cara_z0": {"right": "Cara_x0", "left": "Cara_x1", "top": "Cara_y0", "bottom": "Cara_y1"},
	"Cara_x0": {"right": "Cara_z1", "left": "Cara_z0", "top": "Cara_y0", "bottom": "Cara_y1"},
	"Cara_z1": {"right": "Cara_x1", "left": "Cara_x0", "top": "Cara_y0", "bottom": "Cara_y1"},
	"Cara_x1": {"right": "Cara_z0", "left": "Cara_z1", "top": "Cara_y0", "bottom": "Cara_y1"},
	"Cara_y0": {"left": "Cara_z0", "bottom": "Cara_x0", "right": "Cara_z1", "top": "Cara_x1"},
	"Cara_y1": {"left": "Cara_z0", "top": "Cara_x0", "right": "Cara_z1", "bottom": "Cara_x1"},
}

const FACE_CANONICAL_YAW: Dictionary = {
	"Cara_z0": 0.0,
	"Cara_x0": PI / 2.0,
	"Cara_z1": PI,
	"Cara_x1": 3.0 * PI / 2.0,
}

var _camera: Camera3D
var _is_transitioning := false
var _yaw := 0.0
var _pitch := 0.0
var _face_nodes: Dictionary = {}

func _ready() -> void:
	_camera = $Camera3D
	_face_nodes = {
		"Cara_z0": $Cara_z0/SubViewport_z0/Cara_z0,
		"Cara_x0": $Cara_x0/SubViewport_x0/Cara_x0,
		"Cara_z1": $Cara_z1/SubViewport_z1/Cara_z1,
		"Cara_x1": $Cara_x1/SubViewport_x1/Cara_x1,
		"Cara_y0": $Cara_y0/SubViewport_y0/Cara_y0,
		"Cara_y1": $Cara_y1/SubViewport_y1/Cara_y1,
	}
	for face_name in _face_nodes:
		_face_nodes[face_name].player_exiting.connect(
			_on_player_exiting.bind(face_name)
		)

func _on_player_exiting(side: String, transverse_pos: float, player_vel: Vector2, from_name: String) -> void:
	if _is_transitioning:
		return
	var to_name: String = ADJACENCY[from_name][side]
	_do_transition(from_name, to_name, transverse_pos, player_vel)

func _do_transition(from_name: String, to_name: String, transverse_pos: float, vel: Vector2) -> void:
	_is_transitioning = true

	var from_face: Node2D = _face_nodes[from_name]
	var to_face: Node2D = _face_nodes[to_name]

	var player: CharacterBody2D = from_face.get_node_or_null("bola_2d")
	if player == null:
		_is_transitioning = false
		return

	player.reparent(to_face, false)
	player.position = _compute_entry_pos(from_name, to_name, transverse_pos)
	player.velocity = vel

	var target_yaw: float
	var target_pitch: float
	var to_is_y := to_name in ["Cara_y0", "Cara_y1"]
	var from_is_y := from_name in ["Cara_y0", "Cara_y1"]

	if to_is_y:
		# Yaw fijo al de x0 (PI/2) para que y0/y1 siempre se vean igual
		target_yaw = _nearest_yaw_to(_yaw, PI / 2.0)
		target_pitch = PI / 2.0 if to_name == "Cara_y0" else -PI / 2.0
	elif from_is_y:
		target_yaw = _nearest_yaw_to(_yaw, FACE_CANONICAL_YAW[to_name])
		target_pitch = 0.0
	else:
		# Lateral → lateral: determinar delta de yaw por dirección de adyacencia
		var delta := _lateral_yaw_delta(from_name, to_name)
		target_yaw = _yaw + delta
		target_pitch = 0.0

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_update_camera_vec,
		Vector2(_yaw, _pitch), Vector2(target_yaw, target_pitch),
		TRANSITION_DURATION)
	tween.tween_callback(_on_transition_done)

# Devuelve +PI/2 o -PI/2 según si to_name está a la derecha o izquierda de from_name
func _lateral_yaw_delta(from_name: String, to_name: String) -> float:
	var adj: Dictionary = ADJACENCY[from_name]
	if adj.get("right") == to_name:
		return PI / 2.0
	return -PI / 2.0

# Calcula la posición de entrada en to_face.
# Las transiciones lateral↔lateral usan el eje opuesto al de salida.
# Las transiciones con y0/y1 usan la geometría real del viewport 3D.
# Derivación: y0 right=-Z down=+X, y1 right=-Z down=-X, todas las laterales down=-Y.
# La coordenada transversal se invierte cuando la cara origen es "opuesta" (z1, x1).
func _compute_entry_pos(from_name: String, to_name: String, t: float) -> Vector2:
	var V := VIEWPORT_SIZE
	var E := ENTRY_OFFSET
	var ti := V - t  # transversal invertida

	match [from_name, to_name]:
		# ── Lateral → y0 (salida por "top" de la lateral) ──────────────────
		# z0: entra borde izquierdo de y0 (y0.left = z0), Y directa
		["Cara_z0", "Cara_y0"]:  return Vector2(E,     t)
		# x0: entra borde inferior de y0 (y0.bottom = x0), X directa
		["Cara_x0", "Cara_y0"]:  return Vector2(t,     V - E)
		# z1: entra borde derecho de y0 (y0.right = z1), Y invertida
		["Cara_z1", "Cara_y0"]:  return Vector2(V - E, ti)
		# x1: entra borde superior de y0 (y0.top = x1), X invertida
		["Cara_x1", "Cara_y0"]:  return Vector2(ti,    E)

		# ── Lateral → y1 (salida por "bottom" de la lateral) ────────────────
		# z0: entra borde izquierdo de y1, Y invertida (y1 down=-X ≠ y0)
		["Cara_z0", "Cara_y1"]:  return Vector2(E,     ti)
		# x0: entra borde superior de y1 (y1.top = x0), X directa
		["Cara_x0", "Cara_y1"]:  return Vector2(t,     E)
		# z1: entra borde derecho de y1, Y directa
		["Cara_z1", "Cara_y1"]:  return Vector2(V - E, t)
		# x1: entra borde inferior de y1 (y1.bottom = x1), X invertida
		["Cara_x1", "Cara_y1"]:  return Vector2(ti,    V - E)

		# ── y0 → Lateral (sale de y0, entra por "top" de la lateral) ────────
		["Cara_y0", "Cara_z0"]:  return Vector2(t,     E)
		["Cara_y0", "Cara_x0"]:  return Vector2(t,     E)
		["Cara_y0", "Cara_z1"]:  return Vector2(ti,    E)
		["Cara_y0", "Cara_x1"]:  return Vector2(ti,    E)

		# ── y1 → Lateral (sale de y1, entra por "bottom" de la lateral) ─────
		["Cara_y1", "Cara_x0"]:  return Vector2(t,     V - E)
		["Cara_y1", "Cara_z0"]:  return Vector2(ti,    V - E)
		["Cara_y1", "Cara_z1"]:  return Vector2(t,     V - E)
		["Cara_y1", "Cara_x1"]:  return Vector2(ti,    V - E)

		# ── Lateral → Lateral ────────────────────────────────────────────────
		# "right": entra por borde izquierdo; "left": entra por borde derecho
		_:
			# Determinar si el destino está a la derecha o izquierda
			if ADJACENCY[from_name].get("right") == to_name:
				return Vector2(E,     t)
			else:
				return Vector2(V - E, t)

func _nearest_yaw_to(current: float, canonical: float) -> float:
	var diff := fmod(canonical - current, TAU)
	if diff < -PI:
		diff += TAU
	elif diff > PI:
		diff -= TAU
	return current + diff

func _update_camera_vec(angles: Vector2) -> void:
	_yaw = angles.x
	_pitch = angles.y
	_apply_camera(_yaw, _pitch)

func _apply_camera(yaw: float, pitch: float) -> void:
	_camera.position = Vector3(
		CAMERA_RADIUS * sin(yaw) * cos(pitch),
		CAMERA_RADIUS * sin(pitch),
		CAMERA_RADIUS * cos(yaw) * cos(pitch)
	)
	_camera.look_at(Vector3.ZERO, Vector3(
		-sin(yaw) * sin(pitch),
		cos(pitch),
		-cos(yaw) * sin(pitch)
	))

func _on_transition_done() -> void:
	_is_transitioning = false
