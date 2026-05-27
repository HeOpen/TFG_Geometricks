extends StaticBody3D

@export var id_llave_requerida: String = "llave_sotano"
@onready var hitbox_sotano: CollisionShape3D = $"../../Cabin_Amueblada/tapa_sotano/CollisionShape3D"

var texto_interfaz: String = "Desbloquear trampilla [E]"

func interactuar() -> void:
		
	# Consultamos a tu gestor global si el jugador tiene el string de la llave
	if InventoryManager.tiene_item(id_llave_requerida):
		_abrir_candado()
	else:
		# Aquí conectas tu sistema de UI para mostrar el mensaje
		texto_interfaz = "Está cerrado... necesito una llave roja"
		await get_tree().create_timer(2.0).timeout
		print("Está cerrado. Necesito la llave roja (", id_llave_requerida, ").")
		
		if not _abrir_candado:
			texto_interfaz = "Desbloquear trampilla [E]"

func _abrir_candado() -> void:
		
	# Opcional: Eliminar la llave del inventario si es de un solo uso
	InventoryManager.quitar_item(id_llave_requerida)
	hitbox_sotano.disabled = true
	
		
	# 3. Destruimos este candado cerrado
	queue_free()
