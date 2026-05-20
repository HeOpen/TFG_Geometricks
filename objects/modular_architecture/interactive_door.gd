extends Node3D

# Al usar String, en el Inspector aparecerá un campo de texto en lugar de una casilla de nodo.
@export var destination_name: String = ""

func interact(player_node: CharacterBody3D):
	# Verificación de seguridad
	if destination_name == "":
		push_error("Error crítico: Puerta sin nombre de destino configurado.")
		return
		
	# Pedimos al árbol principal que busque de forma recursiva un nodo que tenga este nombre exacto
	# Parámetros find_child: (Nombre_del_nodo, Búsqueda_Recursiva=true, Propiedad_estricta=false)
	var marker_node = get_tree().get_root().find_child(destination_name, true, false)
	
	# Validamos que el nodo existe y que es del tipo correcto antes de ejecutar la teletransportación
	if marker_node != null and marker_node is Marker3D:
		TransitionManager.execute_door_transition(player_node, marker_node.global_position)
	else:
		push_error("Error crítico: No se encontró ningún Marker3D en el nivel llamado: " + destination_name)
