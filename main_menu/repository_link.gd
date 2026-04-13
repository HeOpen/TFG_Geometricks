extends StaticBody3D

const REPO_URL = "https://github.com/HEOPEN/TFG_GEOMETRICKS"

func _ready():
	# Opcion que detecta el ratón
	input_ray_pickable = true
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _input_event(_camera, event, _position, _normal, _shape_idx):
	# Detectamos el clic izquierdo del ratón
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Abriendo GitHub...")
		OS.shell_open(REPO_URL)

func _on_mouse_entered():
	create_tween().tween_property(self, "scale", Vector3(1.1 ,1.1 ,1.1), 0.1)
func _on_mouse_exited():
	create_tween().tween_property(self, "scale", Vector3(1, 1, 1), 0.1)
