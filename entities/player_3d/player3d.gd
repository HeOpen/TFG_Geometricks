# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

@export var can_move : bool = true
@export var has_gravity : bool = true
@export var can_jump : bool = true
@export var can_sprint : bool = false
@export var can_freefly : bool = false

@export_group("Speeds")
@export var look_speed : float = 0.002
@export var base_speed : float = 7.0
@export var jump_velocity : float = 4.5
@export var sprint_speed : float = 10.0
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_forward : String = "ui_up"
@export var input_back : String = "ui_down"
@export var input_jump : String = "ui_accept"
@export var input_sprint : String = "sprint"
@export var input_freefly : String = "freefly"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var texto_centro = $CanvasLayer/Control/TextoCentro
@onready var barra_inventario = $CanvasLayer/Control/InventarioUI

func _ready() -> void:
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	InventoryManager.inventario_actualizado.connect(_actualizar_ui_inventario)
	texto_centro.text = ""

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Use velocity to actually move
	move_and_slide()

func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false

@onready var interaction_raycast = $Head/Camera3D/RayCast3D

func _input(event):
	
	# Cuando el jugador presione la tecla de interactuar (ej. 'E' o botón de acción)
	if event.is_action_pressed("interactuar"):
		print("Jugador pulsó E")
		
		# Verificamos si el raycast está colisionando con algo
		if interaction_raycast.is_colliding():
			print("Raycast tocó en algo")
			
			# Obtenemos el objeto físico contra el que chocó el rayo (ej. la puerta)
			var hit_object = interaction_raycast.get_collider()
			
			# Verificamos si ese objeto tiene la función "interact" programada
			if hit_object.has_method("interactuar"):
				# Llamamos a la función y le pasamos el propio jugador (self) como argumento
				hit_object.interactuar()

func _process(_delta: float) -> void:
	# 1. Comprobamos si el rayo detecta colisión física
	if raycast.is_colliding():
		var objeto = raycast.get_collider()
		
		# 2. VALIDACIÓN DE SEGURIDAD (El cortafuegos)
		# Comprobamos que el objeto realmente existe en memoria antes de leerlo
		if objeto != null:
			
			# 3. Validamos si pertenece a nuestro sistema de inventario
			if objeto.is_in_group("interactuable"):
				# Dibujamos el texto en la interfaz
				texto_centro.text = objeto.texto_interfaz
				
				# 4. Capturamos la entrada del usuario
				if Input.is_action_just_pressed("interactuar"):
					objeto.interactuar()
			else:
				# Si choca con una pared normal, limpiamos el texto
				texto_centro.text = ""
		else:
			# Si el objeto es un remanente destruido (null), limpiamos el texto
			texto_centro.text = ""
	else:
		# Si el rayo apunta al vacío, limpiamos el texto
		texto_centro.text = ""

func _actualizar_ui_inventario() -> void:
	# Borramos los iconos viejos
	for hijo in barra_inventario.get_children():
		hijo.queue_free()
	
	# Creamos un icono nuevo por cada ítem en la memoria global
	for id_item in InventoryManager.items:
		var icono = TextureRect.new()
		icono.texture = InventoryManager.iconos_items[id_item]
		icono.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		icono.custom_minimum_size = Vector2(64, 64)
		barra_inventario.add_child(icono)
