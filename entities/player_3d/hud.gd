extends Control

# --- REFERENCIAS DE INTERFAZ ---
@export var label_tiempo: Label
@export var label_formas: Label

# --- REFERENCIAS DE LÓGICA ---
var temporizador_nivel: Timer

func _ready() -> void:
	# Localizamos de forma segura el nodo raíz del escenario activo
	var escena_actual = get_tree().current_scene
	
	# Buscamos el temporizador utilizando una ruta relativa segura
	if escena_actual and escena_actual.has_node("Timer_CuentraAtras15"):
		temporizador_nivel = escena_actual.get_node("Timer_CuentraAtras15") as Timer
	else:
		push_warning("HUD: No se encontró el nodo 'Timer_CuentraAtras15' en la escena actual.")

func _process(_delta: float) -> void:
	_actualizar_cronometro()
	_actualizar_contador_inventario()

func _actualizar_cronometro() -> void:
	# Si el temporizador no está listo o ha sido congelado en el sótano, abortamos
	if not temporizador_nivel or temporizador_nivel.is_stopped():
		return
		
	var tiempo_segundos: float = temporizador_nivel.time_left
	
	# Operaciones matemáticas elementales para descomponer el tiempo
	var minutos: int = int(tiempo_segundos / 60.0)
	var segundos: int = int(tiempo_segundos) % 60
	
	# Formateo de texto mediante el operador de máscara de cadena
	label_tiempo.text = "%02d:%02d" % [minutos, segundos]

func _actualizar_contador_inventario() -> void:
	var formas_encontradas: int = 0
	
	# Filtramos el inventario global buscando cadenas específicas
	for item_id in InventoryManager.items:
		if item_id.begins_with("item_"):
			formas_encontradas += 1
			
	label_formas.text = "Formas: %d / 4" % formas_encontradas
