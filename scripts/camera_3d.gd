extends Camera3D

var target: Node3D
@export var distance: float = 10.0
@export var rotation_speed: float = 8.5

var orientation: Basis
var target_orientation: Basis
var _auto_speed: float = 0.0

func _ready() -> void:
	target = get_parent()
	global_position = target.global_position + Vector3(0, 0, distance)
	look_at(target.global_position, Vector3.UP)
	orientation = global_transform.basis
	target_orientation = orientation

func rotate_to_face(face_dir: Vector3, speed: float = 5) -> void:
	var horizontal := Vector3(face_dir.x, 0, face_dir.z)
	if horizontal.length() < 0.1:
		return
	var new_z := horizontal.normalized()
	var new_y := Vector3(0, 1, 0)
	var new_x := new_y.cross(new_z).normalized()
	target_orientation = Basis(new_x, new_y, new_z)
	_auto_speed = speed

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cam_left"):
		target_orientation = Basis(target_orientation.y.normalized(), deg_to_rad(-90)) * target_orientation
	if Input.is_action_just_pressed("cam_right"):
		target_orientation = Basis(target_orientation.y.normalized(), deg_to_rad(90)) * target_orientation
	if Input.is_action_just_pressed("cam_up"):
		target_orientation = Basis(target_orientation.x.normalized(), deg_to_rad(-90)) * target_orientation
	if Input.is_action_just_pressed("cam_down"):
		target_orientation = Basis(target_orientation.x.normalized(), deg_to_rad(90)) * target_orientation
	if Input.is_action_just_pressed("cam_roll_left"):
		target_orientation = Basis(target_orientation.z.normalized(), deg_to_rad(-90)) * target_orientation
	if Input.is_action_just_pressed("cam_roll_right"):
		target_orientation = Basis(target_orientation.z.normalized(), deg_to_rad(90)) * target_orientation

	var speed := _auto_speed if _auto_speed > 0.0 else rotation_speed
	orientation = orientation.slerp(target_orientation, speed * delta)
	if _auto_speed > 0.0 and orientation.is_equal_approx(target_orientation):
		_auto_speed = 0.0

	global_transform = Transform3D(orientation, target.global_position + orientation.z * distance)
