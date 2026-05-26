extends StaticBody3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_nevera: CollisionShape3D = $Hitbox

var esta_abierta: bool = false
var texto_interfaz: String = "Abrir Puerta [E]"

func interactuar() -> void:
	texto_interfaz = ""
	hitbox_nevera.disabled = true
	# Bloqueo lógico: si ya está abierta, ignoramos los clics adicionales
	if esta_abierta:
		return
		
	esta_abierta = true
	anim_player.play("AbriendoPuerta")
