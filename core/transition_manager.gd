extends Node

# Precarga la escena/animacion de abrir la puerta para no ralentizar el juego
var door_anim_scene = preload("res://level/3d_cabin/door_animation.tscn")

# Esta función será llamada cuando el jugador interactúe con una puerta en el nivel
func execute_door_transition(player_node: CharacterBody3D, target_position: Vector3):
	
	# Deshabilita fisica e input del jugador, para que no se mueva ni se caiga
	player_node.set_physics_process(false)
	player_node.set_process_input(false)
	
	# 2. Instancia la animación
	var anim_instance = door_anim_scene.instantiate()
	
	# La añadimos como hija directa del Root (fuera del nivel actual)
	get_tree().root.add_child(anim_instance)
	
	# Obtenemos el AnimationPlayer de la instancia
	var anim_player = anim_instance.get_node("AnimationPlayer")
	
	# Conectamos una señal que escuche cuándo termina exactamente la animación "Opening_Door"
	# Usamos .bind() para pasarle a la función las variables que necesitamos conservar
	anim_player.animation_finished.connect(_on_door_opened.bind(anim_instance, player_node, target_position))
	
	# Reproducimos la animación
	anim_player.play("Opening_Door")

# Esta función se ejecuta automáticamente cuando los 5 segundos de animación terminan
func _on_door_opened(anim_name: StringName, anim_instance: Node, player_node: CharacterBody3D, target_position: Vector3):
	
	# Movemos físicamente al jugador a su nuevo destino (al otro lado de la puerta en el mapa)
	player_node.global_position = target_position
	
	# Destruimos la escena de animación. Al desaparecer su Camera3D, 
	# Godot volverá automáticamente a la Camera3D original del jugador.
	anim_instance.queue_free()
	
	# Devolvemos el control al jugador
	player_node.set_physics_process(true)
	player_node.set_process_input(true)
