extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 5.0
const GRAVITY_STRENGTH = 9.8
const FLOAT_SPEED = 2.0

@export var cube_half_size: float = 10.0
const SPHERE_RADIUS = 0.4

enum Forma { ESFERA, CUBO, PIRAMIDE }
var forma_actual: Forma = Forma.ESFERA

var current_face_dir: Vector3 = Vector3(0, 0, 1)
const FACE_THRESHOLD = 0.5

@onready var camera = $Camera3D
@onready var mesh = $MeshInstance3D
@onready var col_shape = $CollisionShape3D

var mesh_esfera: Mesh
var mesh_cubo: BoxMesh
var mesh_piramide: ArrayMesh

var shape_esfera: SphereShape3D
var shape_cubo: BoxShape3D
var shape_piramide: ConvexPolygonShape3D

func _ready() -> void:
	_init_current_face()
	mesh_esfera = mesh.mesh
	var mat: Material = mesh_esfera.surface_get_material(0)

	mesh_cubo = BoxMesh.new()
	mesh_cubo.size = Vector3(1.0, 1.0, 1.0)
	mesh_cubo.material = mat

	mesh_piramide = _crear_mesh_piramide(mat)

	shape_esfera = SphereShape3D.new()
	shape_esfera.radius = 0.5

	shape_cubo = BoxShape3D.new()
	shape_cubo.size = Vector3(1.0, 1.0, 1.0)

	shape_piramide = _crear_shape_piramide()

func _crear_mesh_piramide(mat: Material) -> ArrayMesh:
	var apex = Vector3(0.0,  0.5,  0.0)
	var bl   = Vector3(-0.5, -0.5,  0.5)
	var br   = Vector3( 0.5, -0.5,  0.5)
	var tr   = Vector3( 0.5, -0.5, -0.5)
	var tl   = Vector3(-0.5, -0.5, -0.5)

	var verts = PackedVector3Array([
		bl, tr, br,
		bl, tl, tr,
		bl, br, apex,
		br, tr, apex,
		tr, tl, apex,
		tl, bl, apex,
	])

	var normals = PackedVector3Array()
	normals.resize(verts.size())
	for i in range(0, verts.size(), 3):
		var n = (verts[i+1] - verts[i]).cross(verts[i+2] - verts[i]).normalized()
		normals[i] = n; normals[i+1] = n; normals[i+2] = n

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals

	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	arr_mesh.surface_set_material(0, mat)
	return arr_mesh

func _crear_shape_piramide() -> ConvexPolygonShape3D:
	var shape = ConvexPolygonShape3D.new()
	shape.points = PackedVector3Array([
		Vector3(-0.5, -0.5,  0.5),
		Vector3( 0.5, -0.5,  0.5),
		Vector3( 0.5, -0.5, -0.5),
		Vector3(-0.5, -0.5, -0.5),
		Vector3( 0.0,  0.5,  0.0),
	])
	return shape

func _aplicar_forma(forma: Forma) -> void:
	match forma:
		Forma.ESFERA:
			mesh.mesh = mesh_esfera
			col_shape.shape = shape_esfera
		Forma.CUBO:
			mesh.mesh = mesh_cubo
			col_shape.shape = shape_cubo
			mesh.transform.basis = Basis.IDENTITY
		Forma.PIRAMIDE:
			mesh.mesh = mesh_piramide
			col_shape.shape = shape_piramide
			mesh.transform.basis = Basis.IDENTITY

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("forma_siguiente"):
		forma_actual = (forma_actual + 1) % Forma.size() as Forma
		_aplicar_forma(forma_actual)
	elif Input.is_action_just_pressed("forma_anterior"):
		forma_actual = (forma_actual - 1 + Forma.size()) % Forma.size() as Forma
		_aplicar_forma(forma_actual)

	var gravity_dir = -(camera.global_transform.basis.y).normalized()
	var gravity = gravity_dir * GRAVITY_STRENGTH
	var up = -gravity_dir

	if forma_actual != Forma.PIRAMIDE and not is_on_floor():
		velocity += gravity * delta

	var gravity_vel = velocity.dot(gravity_dir) * gravity_dir

	match forma_actual:
		Forma.ESFERA:
			# Puede moverse, no puede saltar
			var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
			var cam_basis = camera.global_transform.basis
			var forward = (-cam_basis.z - up * (-cam_basis.z).dot(up)).normalized()
			var right = (cam_basis.x - up * cam_basis.x.dot(up)).normalized()
			var direction = (forward * -input_dir.y + right * input_dir.x).normalized()
			if direction:
				velocity = direction * SPEED + gravity_vel
			else:
				var move_vel = (velocity - gravity_vel).move_toward(Vector3.ZERO, SPEED)
				velocity = move_vel + gravity_vel

		Forma.CUBO:
			# No puede moverse, puede saltar
			var move_vel = (velocity - gravity_vel).move_toward(Vector3.ZERO, SPEED)
			velocity = move_vel + gravity_vel
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity += up * JUMP_VELOCITY

		Forma.PIRAMIDE:
			# No puede moverse, sube linealmente (gravedad cancelada)
			var move_vel = (velocity - gravity_vel).move_toward(Vector3.ZERO, SPEED)
			velocity = move_vel + up * FLOAT_SPEED

	up_direction = up
	move_and_slide()

	if forma_actual == Forma.ESFERA:
		var horizontal_vel = velocity - velocity.dot(gravity_dir) * gravity_dir
		if horizontal_vel.length() > 0.01:
			var roll_axis_world = up.cross(horizontal_vel).normalized()
			var roll_angle = horizontal_vel.length() * delta / SPHERE_RADIUS
			var roll_basis = Basis(roll_axis_world, roll_angle)
			mesh.transform.basis = (roll_basis * mesh.transform.basis).orthonormalized()

	var pos = global_position
	global_position = Vector3(
		clamp(pos.x, -cube_half_size, cube_half_size),
		clamp(pos.y, -cube_half_size, cube_half_size),
		clamp(pos.z, -cube_half_size, cube_half_size)
	)
	_check_face_change()

func _init_current_face() -> void:
	var pos = global_position
	var hs = cube_half_size
	var faces = [
		[Vector3(0, -1, 0), pos.y + hs],
		[Vector3(0,  1, 0), hs - pos.y],
		[Vector3(-1, 0, 0), pos.x + hs],
		[Vector3( 1, 0, 0), hs - pos.x],
		[Vector3(0, 0, -1), pos.z + hs],
		[Vector3(0, 0,  1), hs - pos.z],
	]
	var min_dist = INF
	for face in faces:
		if face[1] < min_dist:
			min_dist = face[1]
			current_face_dir = face[0]

func _check_face_change() -> void:
	var pos = global_position
	var hs = cube_half_size
	var faces = [
		[Vector3(0, -1, 0), pos.y + hs],
		[Vector3(0,  1, 0), hs - pos.y],
		[Vector3(-1, 0, 0), pos.x + hs],
		[Vector3( 1, 0, 0), hs - pos.x],
		[Vector3(0, 0, -1), pos.z + hs],
		[Vector3(0, 0,  1), hs - pos.z],
	]
	var best_dir = current_face_dir
	var min_dist = FACE_THRESHOLD
	for face in faces:
		if face[1] < min_dist:
			min_dist = face[1]
			best_dir = face[0]
	if min_dist < FACE_THRESHOLD and not best_dir.is_equal_approx(current_face_dir):
		current_face_dir = best_dir
		camera.rotate_to_face(best_dir)
