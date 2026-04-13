@tool
extends Area3D

# --- Señales ---
signal presionado(nombre)

# --- Variables del Inspector ---
@export var texto_boton: String = "Botón":
	set(valor):
		texto_boton = valor
		if is_node_ready(): actualizar_visuales()

@export_group("Colores")
@export var color_normal: Color = Color("6B1615")
@export var color_hover: Color = Color("991615")

# --- Referencias ---
@onready var label = $Label3D
@onready var mesh_instance = $MeshInstance3D

func _ready():
	# Solo conectamos interacción si estamos JUGANDO, no en el EDITOR
	if not Engine.is_editor_hint():
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
	
	actualizar_visuales()

func actualizar_visuales():
	if label: label.text = texto_boton
	cambiar_color(color_normal)

# --- Interacción ---
func _on_mouse_entered():
	cambiar_color(color_hover)
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector3(0.20, 0.20, 0.20), 0.2)

func _on_mouse_exited():
	cambiar_color(color_normal)
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector3(0.17,0.17,0.17), 0.2)

func _input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		presionado.emit(texto_boton) # ¡Avisamos al menú!

func cambiar_color(nuevo_color: Color):
	if mesh_instance:
		var mat = mesh_instance.get_active_material(0)
		if mat: mat.albedo_color = nuevo_color
