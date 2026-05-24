extends StaticBody3D

@export var id_del_item: String = "llave_sotano"
@export var texto_interfaz: String = "Coger Llave [E]"

# Variable de estado (El fusible)
var ya_recogido: bool = false

func interactuar() -> void:
	# 1. Si el fusible está fundido, abortamos la ejecución instantáneamente
	if ya_recogido == true:
		return
		
	# 2. Fundimos el fusible para bloquear futuras lecturas en este mismo fotograma
	ya_recogido = true
	
	# 3. Lógica normal
	InventoryManager.anadir_item(id_del_item)
	queue_free()
