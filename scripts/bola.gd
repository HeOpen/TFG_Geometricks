extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 5.0
const GRAVITY_STRENGTH = 9.8

@export var cube_half_size: float = 10.0

@onready var camera = $Camera3D

func _physics_process(delta: float) -> void:
	var gravity_dir = -(camera.global_transform.basis.y).normalized()
	var gravity = gravity_dir * GRAVITY_STRENGTH

	if not is_on_floor():
		velocity += gravity * delta

	var up = -gravity_dir

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity += up * JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var cam_basis = camera.global_transform.basis
	var forward = -cam_basis.z
	var right = cam_basis.x

	forward = (forward - up * forward.dot(up)).normalized()
	right = (right - up * right.dot(up)).normalized()

	var direction = (forward * -input_dir.y + right * input_dir.x).normalized()

	# Separar el componente de gravedad para que el movimiento no lo machaque
	var gravity_vel = velocity.dot(gravity_dir) * gravity_dir

	if direction:
		velocity = direction * SPEED + gravity_vel
	else:
		var move_vel = velocity - gravity_vel
		move_vel = move_vel.move_toward(Vector3.ZERO, SPEED)
		velocity = move_vel + gravity_vel

	up_direction = up
	move_and_slide()

	# Mantener al player dentro del cubo
	var pos = global_position
	global_position = Vector3(
		clamp(pos.x, -cube_half_size, cube_half_size),
		clamp(pos.y, -cube_half_size, cube_half_size),
		clamp(pos.z, -cube_half_size, cube_half_size)
	)
