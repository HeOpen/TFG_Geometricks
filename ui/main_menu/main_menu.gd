extends Node3D

# --- Referencias a Nodos ---
@onready var global_env = $Env/WorldEnvironment.environment
@onready var cubo = $CuboMilenario
@onready var efecto_vhs = $CanvasLayer/VHS_Filter
@onready var sfx_boton = $SFX_Boton
@onready var sfx_narrator = $SFX_Title

# --- Constantes de Valores por Defecto ---
# El audio en Godot utiliza valores lineales (0.0 a 1.0) que luego convertimos a decibelios (dB)
const DEFAULT_MUSIC_VOLUME: float = 0.7  # 70% del volumen total
const DEFAULT_FX_VOLUME: float = 0.8     # 80% del volumen total

# Valores de post-procesado estándar del motor
const DEFAULT_BRIGHTNESS: float = 1.0
const DEFAULT_CONTRAST: float = 1.0

# --- Variables de Control ---
var tween_rotacion: Tween

# Rotaciones absolutas en radianes para las caras del cubo
const ANGULO_FRONTAL = 0.0
const ANGULO_DERECHA = deg_to_rad(-90)
const ANGULO_TRASERA = deg_to_rad(-180)
const ANGULO_IZQUIERDA = deg_to_rad(90)

func _ready() -> void:
	# 1. Forzamos al Autoload a cargar el archivo de disco si existe
	PauseMenu.cargar_configuracion()
	
	# 2. Sincronizamos la escena física del menú con los datos globales
	_sincronizar_menu_con_estado_global()
	_conectar_senales_sliders()
	
	MusicManager.reproducir_menu()
	
func _sincronizar_menu_con_estado_global() -> void:
	# Aplicamos el audio del Autoload a los buses del motor
	var bus_musica = AudioServer.get_bus_index("Musica")
	if bus_musica != -1:
		AudioServer.set_bus_volume_db(bus_musica, linear_to_db(PauseMenu.musica_global))
		
	var bus_fx = AudioServer.get_bus_index("FX")
	if bus_fx != -1:
		AudioServer.set_bus_volume_db(bus_fx, linear_to_db(PauseMenu.fx_global))
	
	# Aplicamos el post-procesado del Autoload al entorno del menú
	if global_env:
		global_env.adjustment_brightness = PauseMenu.brillo_global
		global_env.adjustment_contrast = PauseMenu.contraste_global
	
	# Aplicamos el estado del VHS
	if efecto_vhs:
		efecto_vhs.visible = PauseMenu.vhs_activado_global
		
		var boton_vhs = cubo.find_child("Boton_VHS", true, false)
		if boton_vhs != null:
			boton_vhs.texto_boton = "VHS: ON" if PauseMenu.vhs_activado_global else "VHS: OFF"

func _cargar_configuracion_por_defecto() -> void:
	# 1. Inicialización del Subsistema de Audio
	var bus_musica = AudioServer.get_bus_index("Musica")
	if bus_musica != -1:
		AudioServer.set_bus_volume_db(bus_musica, linear_to_db(DEFAULT_MUSIC_VOLUME))
	
	var bus_fx = AudioServer.get_bus_index("FX")
	if bus_fx != -1:
		AudioServer.set_bus_volume_db(bus_fx, linear_to_db(DEFAULT_FX_VOLUME))
	
	# 2. Inicialización del Subsistema de Video (Post-procesado)
	if global_env:
		global_env.adjustment_brightness = DEFAULT_BRIGHTNESS
		global_env.adjustment_contrast = DEFAULT_CONTRAST
	
	# 3. Estado inicial del filtro de pantalla (Apagado por defecto)
	if efecto_vhs:
		efecto_vhs.visible = false
		
		# Sincronizamos la etiqueta del botón con el estado interno real
		var boton_vhs = cubo.find_child("Boton_VHS", true, false)
		if boton_vhs != null:
			boton_vhs.texto_boton = "VHS: OFF"

func _on_boton_presionado(nombre_del_boton: String) -> void:
	print("Botón pulsado: ", nombre_del_boton)
	sfx_boton.play()
	
	match nombre_del_boton:
		# --- NAVEGACIÓN ---
		"OPCIONES":
			_rotar_cubo_hacia(ANGULO_DERECHA)
		"AUDIO":
			_rotar_cubo_hacia(ANGULO_TRASERA)
		"VIDEO":
			_rotar_cubo_hacia(ANGULO_IZQUIERDA)
		"VOLVER":
			if is_equal_approx(cubo.rotation.y, ANGULO_TRASERA) or is_equal_approx(cubo.rotation.y, ANGULO_IZQUIERDA):
				_rotar_cubo_hacia(ANGULO_DERECHA)
			else:
				_rotar_cubo_hacia(ANGULO_FRONTAL)
		
		# --- INTERRUPTOR VHS (Corrección crítica) ---
		# Al separar los términos por comas, el bloque ejecuta la misma función sin importar el texto activo
		# --- INTERRUPTOR VHS ---
		# Añadimos "VHS" a secas por si es el texto que trae del editor
		"VHS", "VHS: ON", "VHS: OFF":
			_alternar_vhs()
		
		# --- ACCIONES ---
		"JUGAR":
			sfx_narrator.play()
			_empezar_juego()
		"SALIR":
			get_tree().quit()

func _rotar_cubo_hacia(angulo_destino_y: float) -> void:
	if tween_rotacion and tween_rotacion.is_valid():
		tween_rotacion.kill()
	
	tween_rotacion = create_tween()
	tween_rotacion.set_trans(Tween.TRANS_SINE)
	tween_rotacion.set_ease(Tween.EASE_IN_OUT)
	tween_rotacion.tween_property(cubo, "rotation:y", angulo_destino_y, 0.6)

func _empezar_juego() -> void:
	# 1. Obtenemos la referencia directa al nodo de animación
	var anim_player = $CanvasLayer/AnimationPlayer
	
	# 2. Disparamos la animación que vuelve el Fade_Rect opaco
	anim_player.play("fade_in") 
	
	# 3. await detiene la lectura de este bloque de código específico.
	# El juego sigue corriendo a 60 FPS, pero esta función no avanzará a la
	# siguiente línea hasta que el AnimationPlayer emita la señal de que ha terminado.
	await anim_player.animation_finished
	
	# 4. Una vez la pantalla es 100% negra, destruimos el menú y cargamos el nivel
	get_tree().change_scene_to_file("res://level/cabin_intro/cabin_intro.tscn")
	
func _alternar_vhs() -> void:
	if not efecto_vhs:
		return
		
	# Modificamos el valor global directamente
	PauseMenu.vhs_activado_global = not PauseMenu.vhs_activado_global
	efecto_vhs.visible = PauseMenu.vhs_activado_global
	
	# Guardamos el cambio inmediatamente en el disco duro
	PauseMenu.guardar_configuracion()
	
	var boton_vhs = cubo.find_child("Boton_VHS", true, false)
	if boton_vhs != null:
		boton_vhs.texto_boton = "VHS: ON" if PauseMenu.vhs_activado_global else "VHS: OFF"
func _conectar_senales_sliders() -> void:
	# --- SLIDER MÚSICA ---
	var area_musica = cubo.find_child("Slider_Musica", true, false)
	if area_musica:
		var ui_musica = area_musica.find_child("HSlider", true, false)
		if ui_musica:
			ui_musica.value = DEFAULT_MUSIC_VOLUME
			
			# Comprobación de seguridad: Solo conectamos si la conexión NO existe
			if not ui_musica.value_changed.is_connected(_on_slider_musica_cambiado):
				ui_musica.value_changed.connect(_on_slider_musica_cambiado)
		else:
			push_error("Error: HSlider no encontrado dentro de Slider_Musica")
			
	# --- SLIDER FX ---
	var area_fx = cubo.find_child("Slider_FX", true, false)
	if area_fx:
		var ui_fx = area_fx.find_child("HSlider", true, false)
		if ui_fx:
			ui_fx.value = DEFAULT_FX_VOLUME
			if not ui_fx.value_changed.is_connected(_on_slider_fx_cambiado):
				ui_fx.value_changed.connect(_on_slider_fx_cambiado)
			
	# --- SLIDER BRILLO ---
	var area_brillo = cubo.find_child("Slider_Brillo", true, false)
	if area_brillo:
		var ui_brillo = area_brillo.find_child("HSlider", true, false)
		if ui_brillo:
			ui_brillo.value = DEFAULT_BRIGHTNESS
			if not ui_brillo.value_changed.is_connected(_on_slider_brillo_cambiado):
				ui_brillo.value_changed.connect(_on_slider_brillo_cambiado)
			
	# --- SLIDER CONTRASTE ---
	var area_contraste = cubo.find_child("Slider_Contraste", true, false)
	if area_contraste:
		var ui_contraste = area_contraste.find_child("HSlider", true, false)
		if ui_contraste:
			ui_contraste.value = DEFAULT_CONTRAST
			if not ui_contraste.value_changed.is_connected(_on_slider_contraste_cambiado):
				ui_contraste.value_changed.connect(_on_slider_contraste_cambiado)

# --- FUNCIONES RECEPTORAS DE SEÑALES ---

# --- Receptores de Sliders Actualizados ---

func _on_slider_musica_cambiado(valor: float) -> void:
	PauseMenu.musica_global = valor
	var bus_musica = AudioServer.get_bus_index("Musica")
	if bus_musica != -1:
		AudioServer.set_bus_volume_db(bus_musica, linear_to_db(valor))
	PauseMenu.guardar_configuracion()

func _on_slider_fx_cambiado(valor: float) -> void:
	PauseMenu.fx_global = valor
	var bus_fx = AudioServer.get_bus_index("FX")
	if bus_fx != -1:
		AudioServer.set_bus_volume_db(bus_fx, linear_to_db(valor))
	PauseMenu.guardar_configuracion()

func _on_slider_brillo_cambiado(valor: float) -> void:
	PauseMenu.brillo_global = valor
	if global_env:
		global_env.adjustment_brightness = valor
	PauseMenu.guardar_configuracion()

func _on_slider_contraste_cambiado(valor: float) -> void:
	PauseMenu.contraste_global = valor
	if global_env:
		global_env.adjustment_contrast = valor
	PauseMenu.guardar_configuracion()
