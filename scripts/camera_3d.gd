extends Camera3D

var target: Node3D
@export var distance: float = 10.0
@export var rotation_speed: float = 8.5

var orientation: Basis
var target_orientation: Basis

func _ready() -> void:
	target = get_parent()
	global_position = target.global_position + Vector3(0, 0, distance)
	look_at(target.global_position, Vector3.UP)
	orientation = global_transform.basis
	target_orientation = orientation

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

	orientation = orientation.slerp(target_orientation, rotation_speed * delta)

	global_transform = Transform3D(orientation, target.global_position + orientation.z * distance)
