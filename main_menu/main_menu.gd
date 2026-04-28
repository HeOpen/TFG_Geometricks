extends Node3D

func _ready():
	pass

func _on_button_presionado(nombre_del_boton):
	print("El jugador pulsó: ", nombre_del_boton)
	
	# match es un switch. Es case sensitive, tenedlo en cuenta
	match nombre_del_boton:
		"JUGAR":
			_empezar_juego()
		"OPCIONES":
			_abrir_opciones()
		"SALIR":
			print("---Saliendo del juego---")
			get_tree().quit() # Cierra el juego

func _empezar_juego():
	print("Cargando nivel...")
	get_tree().change_scene_to_file("res://level/nivel1.tscn")

func _abrir_opciones():
	# Pendiente de desarrollar
	# Debe contemplar:
	# Efectos de sonido, Banda sonora, Fullscreen, Filtro PSX (?)
	print("Abriendo menú de opciones...")
