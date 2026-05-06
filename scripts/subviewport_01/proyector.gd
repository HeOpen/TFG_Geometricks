extends SubViewport

func _ready():
	await get_tree().process_frame
	var mundo_nodo = get_node_or_null("../../ContenedorLogica/Mundo")

	if mundo_nodo:
		self.world_2d = mundo_nodo.get_viewport().world_2d
	else:
		print("Error: No encuentro el nodo Mundo en ../../ContenedorLogica/Mundo")
