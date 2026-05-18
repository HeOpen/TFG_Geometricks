extends Node3D

func _ready():
	pass

func _on_button_presionado(nombre_del_boton):
	print("El jugador pulsó: ", nombre_del_boton)
	
	# match es un switch. Es case sensitive, tenedlo en cuenta
	match nombre_del_boton:
		"JUGAR":
			$Fade_transition.show()
			$Fade_transition/Fade_timer.start()
			$Fade_transition/AnimationPlayer.play("fade_in")
		"OPCIONES":
			_abrir_opciones()
		"SALIR":
			print("---Saliendo del juego---")
			get_tree().quit() # Cierra el juego

func _empezar_juego():
	print("Cargando nivel...")
	get_tree().change_scene_to_file("res://level/3d_cabin/cabin_intro_structure.tscn")

func _abrir_opciones():
	# Pendiente de desarrollar
	# Debe contemplar:
	# Efectos de sonido, Banda sonora, Fullscreen, Filtro PSX (?)
	print("Abriendo menú de opciones...")


func _on_fade_timer_timeout() -> void:
	_empezar_juego()
