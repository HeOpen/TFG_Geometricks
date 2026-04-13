extends Camera3D

var angle = 0.0
var target: Node3D
var distance: float

func _ready() -> void:
	target = get_parent()
	distance = global_position.distance_to(target.global_position)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cam_left"):
		angle -= 90.0
	if Input.is_action_just_pressed("cam_right"):
		angle += 90.0

	var rad = deg_to_rad(angle)
	var height = position.y
	global_position = target.global_position + Vector3(sin(rad), height, cos(rad)) * distance
	look_at(target.global_position, Vector3.UP)
