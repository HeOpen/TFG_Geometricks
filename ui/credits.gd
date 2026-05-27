extends Control

@onready var anim_player: AnimationPlayer = $AnimationPlayer

const RUTA_MENU_PRINCIPAL: String = "res://ui/main_menu/main_menu.tscn"

func _ready() -> void:
	# 1. Aseguramos que el jugador pueda interactuar con el menú posteriormente
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# 2. Conectamos la señal nativa de finalización por código
	anim_player.animation_finished.connect(_on_animacion_terminada)
	
	# 3. Iniciamos el desplazamiento
	anim_player.play("scroll")

func _on_animacion_terminada(_anim_name: String) -> void:
	# 4. Transición de retorno al estado inicial del juego
	get_tree().change_scene_to_file(RUTA_MENU_PRINCIPAL)
