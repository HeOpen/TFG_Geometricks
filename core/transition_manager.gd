extends Node

var door_anim_scene = preload("res://level/3d_cabin/door_animation.tscn")
var en_transicion: bool = false

func execute_door_transition(player_node: CharacterBody3D, target_position: Vector3):
	# 1. Candado de seguridad estricto
	if en_transicion:
		return
	en_transicion = true
	
	# 2. Deshabilitar input y sensores del jugador
	if "can_move" in player_node:
		player_node.can_move = false
		
	# Apagamos el láser para que deje de interactuar temporalmente
	if "raycast" in player_node:
		player_node.raycast.enabled = false
		player_node.texto_centro.text = "" # Forzamos el borrado del texto en pantalla
		
	# 3. Instanciar la animación en la capa superior
	var anim_instance = door_anim_scene.instantiate()
	get_tree().root.add_child(anim_instance)
	
	# 4. Secuestro forzado de la cámara (Transición a modo cinemática)
	var camara_cinematica = anim_instance.find_child("Camera3D", true, false)
	if camara_cinematica != null:
		camara_cinematica.make_current()
	else:
		push_error("Error: Falta Camera3D en door_animation.tscn")
	
	# 5. Reproducción Asíncrona (Sustituye a tu sistema de señales)
	var anim_player = anim_instance.get_node("AnimationPlayer")
	anim_player.play("Opening_Door")
	
	# El código se pausa exactamente aquí hasta que la puerta termine.
	# No necesitas crear una función separada.
	await anim_player.animation_finished
	
	# 6. Ejecución del Teletransporte Matemático
	player_node.global_position = target_position
	
	# 7. Limpieza y Restauración de la Cámara Original
	anim_instance.queue_free()
	
	var camara_jugador = player_node.find_child("Camera3D", true, false)
	if camara_jugador != null:
		camara_jugador.make_current()
		
# 8. Devolver controles y abrir el candado
	if "can_move" in player_node:
		player_node.can_move = true
		
	# Encendemos el láser cuando el jugador ya está en su nuevo destino
	if "raycast" in player_node:
		player_node.raycast.enabled = true
		
	en_transicion = false
