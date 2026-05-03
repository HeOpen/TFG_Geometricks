extends SubViewport

func _ready():
	await get_tree().process_frame
	# Buscamos el nodo Mundo
	var mundo_nodo = get_node_or_null("../../ContenedorLogica/Mundo")
	
	if mundo_nodo:
		# Conectamos este visor al universo del juego
		self.world_2d = mundo_nodo.get_viewport().world_2d
	else:
		print("Error: No encuentro el nodo Mundo")
