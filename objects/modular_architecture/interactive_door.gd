extends StaticBody3D

# --- Referencias Expuestas ---
@export var destination_front: String = ""
@export var destination_back: String = ""

# --- Variables de Interfaz ---
var texto_interfaz: String = "Abrir Puerta [E]"
var en_proceso: bool = false

func interactuar() -> void:
	if en_proceso:
		return
		
	en_proceso = true
	texto_interfaz = ""
	
	# 1. CÁLCULO DE VECTORES (Detección de Lado)
	var player_pos = get_viewport().get_camera_3d().global_position
	
	var door_forward = global_transform.basis.z 
	var direction_to_player = global_position.direction_to(player_pos)
	var dot_product = door_forward.dot(direction_to_player)
	
	# 2. DETERMINACIÓN DEL DESTINO
	var target_name = ""
	if dot_product > 0:
		target_name = destination_front
	else:
		target_name = destination_back
		
	if target_name == "":
		push_error("Error crítico: Un destino está vacío en el Inspector de la puerta.")
		en_proceso = false
		texto_interfaz = "Abrir Puerta [E]"
		return
		
	# 3. EJECUCIÓN GLOBAL (Delegación)
	var marker_node = get_tree().get_root().find_child(target_name, true, false)
	var player_node = get_tree().get_first_node_in_group("Player")
	
	if marker_node != null and marker_node is Marker3D and player_node != null:
		# AWAIT ES OBLIGATORIO AQUÍ.
		# Congela la ejecución de este script hasta que el TransitionManager termine.
		await TransitionManager.execute_door_transition(player_node, marker_node.global_position)
	else:
		push_error("Error crítico: No se encontró el Marker3D o el Jugador en la escena.")
		
	# Estas dos líneas solo se ejecutarán cuando el jugador ya haya sido teletransportado
	# y la animación haya concluido.
	en_proceso = false
	texto_interfaz = "Abrir Puerta [E]"
