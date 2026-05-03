extends CharacterBody2D

# Le damos un valor por defecto de 600.0 para que nunca sea Nil
@export var velocidad_vuelo: float = 600.0 

func _physics_process(_delta):
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Si velocidad_vuelo fuera Nil, aquí daría el error. 
	# Al ponerle ': float = 600.0' arriba, lo evitamos.
	velocity = direccion * velocidad_vuelo 
	move_and_slide()
