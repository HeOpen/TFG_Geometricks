extends Node3D

@export var destination_front: String = ""
@export var destination_back: String = ""

func interact(player_node: CharacterBody3D):
	# 1. Obtenemos el vector frontal de la puerta (Hacia dónde apunta su eje Z local)
	var door_forward = global_transform.basis.z
	
	# 2. Calculamos la dirección exacta desde el centro de la puerta hacia el jugador
	var direction_to_player = global_position.direction_to(player_node.global_position)
	
	# 3. Calculamos el Producto Punto (Dot Product)
	var dot_product = door_forward.dot(direction_to_player)
	
	# 4. Determinamos el destino basado en el resultado matemático
	var target_name = ""
	if dot_product > 0:
		# El jugador está en la parte delantera de la puerta
		target_name = destination_front
	else:
		# El jugador está en la parte trasera de la puerta
		target_name = destination_back
		
	# 5. Verificación de seguridad
	if target_name == "":
		push_error("Error crítico: Destino vacío en la puerta.")
		return
		
	# 6. Búsqueda y ejecución del salto
	var marker_node = get_tree().get_root().find_child(target_name, true, false)
	
	if marker_node != null and marker_node is Marker3D:
		TransitionManager.execute_door_transition(player_node, marker_node.global_position)
	else:
		push_error("Error crítico: No se encontró el Marker3D llamado: " + target_name)
