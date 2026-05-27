extends Node3D

const VIEWPORT_SIZE := 512.0
const TRANSITION_DURATION := 0.8
const CAMERA_RADIUS := 2.0
const ENTRY_OFFSET := 10.0

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
	_is_transitioning = true
	await get_tree().create_timer(1.0).timeout
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

	var nombre_marcador = "EntradaDesde_" + from_name
	var marcador = to_face.find_child(nombre_marcador, true, false) as Marker2D
	
	if marcador != null:
		print("¡ÉXITO! Marcador '", nombre_marcador, "' encontrado en '", to_name, "'. Moviendo a X:", marcador.position.x, " Y:", marcador.position.y)
		player.position = marcador.position
		player.fijar_nuevo_respawn(player.position)
	else:
		print("INFO: No hay marcador '", nombre_marcador, "' en la cara '", to_name, "'. Usando cálculo matemático.")
		player.position = _compute_entry_pos(from_name, to_name, transverse_pos)
		player.fijar_nuevo_respawn(player.position)
	player.velocity = vel

	var target_yaw: float
	var target_pitch: float
	var to_is_y := to_name in ["Cara_y0", "Cara_y1"]
	var from_is_y := from_name in ["Cara_y0", "Cara_y1"]

	if to_is_y:
		target_yaw = _nearest_yaw_to(_yaw, PI / 2.0)
		target_pitch = PI / 2.0 if to_name == "Cara_y0" else -PI / 2.0
	elif from_is_y:
		target_yaw = _nearest_yaw_to(_yaw, FACE_CANONICAL_YAW[to_name])
		target_pitch = 0.0
	else:
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

func _lateral_yaw_delta(from_name: String, to_name: String) -> float:
	var adj: Dictionary = ADJACENCY[from_name]
	if adj.get("right") == to_name:
		return PI / 2.0
	return -PI / 2.0

func _compute_entry_pos(from_name: String, to_name: String, t: float) -> Vector2:
	var V := VIEWPORT_SIZE
	var E := ENTRY_OFFSET
	var ti := V - t

	match [from_name, to_name]:
		["Cara_z0", "Cara_y0"]:  return Vector2(E,     t)
		["Cara_x0", "Cara_y0"]:  return Vector2(t,     V - E)
		["Cara_z1", "Cara_y0"]:  return Vector2(V - E, ti)
		["Cara_x1", "Cara_y0"]:  return Vector2(ti,    E)

		["Cara_z0", "Cara_y1"]:  return Vector2(E,     ti)
		["Cara_x0", "Cara_y1"]:  return Vector2(t,     E)
		["Cara_z1", "Cara_y1"]:  return Vector2(V - E, t)
		["Cara_x1", "Cara_y1"]:  return Vector2(ti,    V - E)

		["Cara_y0", "Cara_z0"]:  return Vector2(t,     E)
		["Cara_y0", "Cara_x0"]:  return Vector2(t,     E)
		["Cara_y0", "Cara_z1"]:  return Vector2(ti,    E)
		["Cara_y0", "Cara_x1"]:  return Vector2(ti,    E)

		["Cara_y1", "Cara_x0"]:  return Vector2(t,     V - E)
		["Cara_y1", "Cara_z0"]:  return Vector2(ti,    V - E)
		["Cara_y1", "Cara_z1"]:  return Vector2(t,     V - E)
		["Cara_y1", "Cara_x1"]:  return Vector2(ti,    V - E)

		_:
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
