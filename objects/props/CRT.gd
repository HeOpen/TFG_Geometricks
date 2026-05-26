extends StaticBody3D

@onready var sub_viewport: SubViewport = $SubViewport
@onready var malla_pantalla: MeshInstance3D = $TV_02

func _ready() -> void:
	# 1. Obtenemos el material de la pantalla asegurando que sea único para esta instancia
	var material_unico = malla_pantalla.get_surface_override_material(2)
	
	if material_unico is StandardMaterial3D:
		# 2. Extraemos la textura del Viewport dinámicamente en tiempo de ejecución
		var textura_viewport = sub_viewport.get_texture()
		
		# 3. Asignamos la textura directamente al canal Albedo por código
		material_unico.albedo_texture = textura_viewport
		
		# 4. Forzamos la emisión para que el vídeo brille en la oscuridad
		material_unico.emission_enabled = true
		material_unico.emission_texture = textura_viewport
