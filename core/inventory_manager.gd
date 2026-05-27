extends Node

# Emitimos esta señal nativa cada vez que cogemos o usamos un ítem para actualizar la interfaz
signal inventario_actualizado

# Almacenaremos identificadores de texto simples (ej: "llave_sotano", "linterna")
var items: Array[String] = []

# Diccionario para mapear el identificador con su textura 2D para la interfaz inferior
var iconos_items: Dictionary = {
	"llave_pcroom": preload("res://assets/textures/Icons/key_icon.png"),
	"vhs_tape": preload("res://assets/textures/Icons/vhs_icon.png"),
	"item_canica_bola" : preload("res://assets/textures/Icons/icon_circulo.png"),
	"item_cuadrado_rubik" : preload("res://assets/textures/Icons/icon_cuadrado.png"),
	"item_rectangulo_memorycard" : preload("res://assets/textures/Icons/icon_rectangulo.png"),
	"item_piramide_illuminati" : preload("res://assets/textures/Icons/icon_triangulo.png"),
	"llave_sotano": preload("res://assets/textures/Icons/key_icon.png")
}

func anadir_item(id_item: String) -> void:
	# 1. Comprobamos si el inventario YA contiene este identificador
	if not tiene_item(id_item):
		items.append(id_item)
		inventario_actualizado.emit()
	else:
		# Si ya lo tiene, lo ignoramos silenciosamente para evitar duplicados en la UI
		push_warning("Intento de duplicar ítem evitado: ", id_item)

func quitar_item(id_item: String) -> void:
	items.erase(id_item)
	inventario_actualizado.emit()

func tiene_item(id_item: String) -> bool:
	return items.has(id_item)
