extends StaticBody3D

@export var id_llave_requerida: String = "llave_pcroom"
@export var escena_candado_abierto: PackedScene
@export var puerta_asignada: Node3D

var texto_interfaz: String = "Desbloquear puerta [E]"

var procesando: bool = false

func interactuar() -> void:
	if procesando:
		return
		
	# Consultamos a tu gestor global si el jugador tiene el string de la llave
	if InventoryManager.tiene_item(id_llave_requerida):
		_abrir_candado()
	else:
		# Aquí conectas tu sistema de UI para mostrar el mensaje
		texto_interfaz = "Está cerrado... necesito una llave naranja"
		await get_tree().create_timer(2.0).timeout
		print("Está cerrado. Necesito la llave naranja (", id_llave_requerida, ").")
		
		if not _abrir_candado:
			texto_interfaz = "Desbloquear puerta [E]"

func _abrir_candado() -> void:
	procesando = true
	
	# 1. Instanciamos el modelo del candado abierto
	if escena_candado_abierto:
		var candado_abierto = escena_candado_abierto.instantiate()
		
		# Lo añadimos al mismo padre que este candado (la cabaña o la puerta)
		get_parent().add_child(candado_abierto)
		
		# Copiamos la Transformación Global (posición, rotación y escala exacta)
		candado_abierto.global_transform = self.global_transform
	else:
		push_error("No has asignado la escena del candado abierto en el Inspector.")

	# 2. Desbloqueamos la puerta lógicamente
	if puerta_asignada and puerta_asignada.has_method("desbloquear"):
		puerta_asignada.desbloquear()
		
	# Opcional: Eliminar la llave del inventario si es de un solo uso
	InventoryManager.quitar_item(id_llave_requerida)
		
	# 3. Destruimos este candado cerrado
	queue_free()
