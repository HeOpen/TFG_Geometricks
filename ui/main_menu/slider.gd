extends Area3D

@onready var sub_viewport: SubViewport = $SubViewport
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	# Vincula la señal de detección de periféricos al evento local
	input_event.connect(_on_input_event)

func _on_input_event(_camera: Camera3D, event: InputEvent, click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	# Discrimina cualquier entrada que no provenga del ratón
	if event is InputEventMouse:
		
		# Obtiene el tamaño físico de la malla en metros.
		var mesh_size: Vector2 = mesh_instance.mesh.size
		
		# Convierte el vector global de impacto a coordenadas locales relativas a la malla.
		# Ejemplo: Si el objeto está en el centro del mundo (0,0,0) y mide 2.0 de ancho, 
		# un clic en el extremo derecho devuelve una posición local X de 1.0.
		var local_pos: Vector3 = mesh_instance.to_local(click_position)
		
		# Normaliza las coordenadas al rango matemático [0.0, 1.0].
		# Sumar la mitad del tamaño compensa el punto de origen central de la malla 3D.
		var uv_x: float = (local_pos.x + (mesh_size.x / 2.0)) / mesh_size.x
		var uv_y: float = (local_pos.y + (mesh_size.y / 2.0)) / mesh_size.y
		
		# Invierte el eje Y. En el espacio 3D, Y positivo asciende. En interfaces 2D, Y positivo desciende.
		uv_y = 1.0 - uv_y
		
		# Multiplica la coordenada normalizada por la resolución real del SubViewport.
		# Ejemplo: uv_x de 0.5 * resolución X de 256px = inyección en el píxel 128.
		var viewport_pos: Vector2 = Vector2(uv_x * sub_viewport.size.x, uv_y * sub_viewport.size.y)
		
		# Duplica el evento original del sistema para preservar metadatos (ej. si es clic izquierdo o derecho),
		# inyecta las nuevas coordenadas calculadas, y lo empuja al hilo de ejecución del SubViewport.
		var event_2d: InputEvent = event.duplicate()
		event_2d.position = viewport_pos
		sub_viewport.push_input(event_2d)
