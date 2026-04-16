extends Camera3D

var target: Node3D
@export var distance: float = 10.0
var orientation: Basis

func _ready() -> void:
	target = get_parent()
	global_position = target.global_position + Vector3(0, 0, distance)
	look_at(target.global_position, Vector3.UP)
	orientation = global_transform.basis

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cam_left"):
		orientation = Basis(orientation.y.normalized(), deg_to_rad(-90)) * orientation
	if Input.is_action_just_pressed("cam_right"):
		orientation = Basis(orientation.y.normalized(), deg_to_rad(90)) * orientation
	if Input.is_action_just_pressed("cam_up"):
		orientation = Basis(orientation.x.normalized(), deg_to_rad(-90)) * orientation
	if Input.is_action_just_pressed("cam_down"):
		orientation = Basis(orientation.x.normalized(), deg_to_rad(90)) * orientation
	if Input.is_action_just_pressed("cam_roll_left"):
		orientation = Basis(orientation.z.normalized(), deg_to_rad(-90)) * orientation
	if Input.is_action_just_pressed("cam_roll_right"):
		orientation = Basis(orientation.z.normalized(), deg_to_rad(90)) * orientation
	global_position = target.global_position + orientation.z * distance
	global_transform.basis = orientation
