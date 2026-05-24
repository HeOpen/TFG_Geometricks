extends StaticBody3D

# --- Variables Expuestas ---
@export var id_requerido: String = "vhs_tape"

# --- Variables de Estado ---
var texto_interfaz: String = "Insertar Cinta [E]"
var reproduciendo: bool = false
	
	
func interactuar() -> void:
	# 1. Candado de estado: Si ya está reproduciendo, ignorar interacción
	if reproduciendo:
		return
		
	# 2. Validación de Base de Datos: Preguntamos al Autoload
	if InventoryManager.tiene_item(id_requerido):
		reproduciendo = true
		texto_interfaz = "Reproduciendo..."
		
		# 3. Consumo del ítem (Opcional: puedes dejarlo si quieres que el jugador conserve la cinta)
		InventoryManager.quitar_item(id_requerido)
		
		# 4. (Opcional) Reproducir un SFX físico de "clac" mecánico del VHS aquí
		
		var anim_player = $"../CanvasLayer/AnimationPlayer"
		anim_player.play("fade_in")
		await anim_player.animation_finished
		get_tree().change_scene_to_file("res://level/3d_cabin/nivel_1.tscn")
	
	else:
		# Feedback visual temporal si no tiene la cinta
		texto_interfaz = "Necesitas una cinta de vídeo."
		await get_tree().create_timer(2.0).timeout
		
		# Verificamos que no se haya insertado en esos 2 segundos antes de restaurar el texto
		if not reproduciendo:
			texto_interfaz = "Insertar Cinta [E]"
"res://level/3d_cabin/nivel_1.tscn"
