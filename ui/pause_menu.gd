extends CanvasLayer

# --- VARIABLES GLOBALES PERSISTENTES ---
var vhs_activado_global: bool = false
var brillo_global: float = 1.0
var contraste_global: float = 1.0
var musica_global: float = 0.7
var fx_global: float = 0.8

var puede_pausar: bool = false

const RUTA_GUARDADO: String = "user://configuracion.cfg"

# --- REFERENCIAS DE INTERFAZ 2D (@export) ---
@export var slider_musica: HSlider
@export var slider_fx: HSlider
@export var slider_brillo: HSlider
@export var slider_contraste: HSlider
@export var boton_vhs: Button
@export var boton_volver: Button
@export var boton_menu_principal: Button

# --- REFERENCIAS DINÁMICAS DEL NIVEL ---
var entorno_actual: Environment
var filtro_vhs_actual: CanvasItem

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Cargamos los ajustes del disco antes de hacer nada más
	cargar_configuracion() 
	
	hide()
	
	# Conexión de señales blindada contra duplicados del editor
	if slider_musica and not slider_musica.value_changed.is_connected(_on_slider_musica_cambiado):
		slider_musica.value_changed.connect(_on_slider_musica_cambiado)
		
	if slider_fx and not slider_fx.value_changed.is_connected(_on_slider_fx_cambiado):
		slider_fx.value_changed.connect(_on_slider_fx_cambiado)
		
	if slider_brillo and not slider_brillo.value_changed.is_connected(_on_slider_brillo_cambiado):
		slider_brillo.value_changed.connect(_on_slider_brillo_cambiado)
		
	if slider_contraste and not slider_contraste.value_changed.is_connected(_on_slider_contraste_cambiado):
		slider_contraste.value_changed.connect(_on_slider_contraste_cambiado)
	
	if boton_volver and not boton_volver.pressed.is_connected(_alternar_pausa):
		boton_volver.pressed.connect(_alternar_pausa)
		
	if boton_vhs and not boton_vhs.pressed.is_connected(_alternar_vhs):
		boton_vhs.pressed.connect(_alternar_vhs)
		
	if boton_menu_principal and not boton_menu_principal.pressed.is_connected(_on_volver_al_menu_presionado):
		boton_menu_principal.pressed.connect(_on_volver_al_menu_presionado)

# --- SISTEMA DE INYECCIÓN DE ESTADO ---

func registrar_y_aplicar_nivel(entorno: Environment, filtro_vhs: CanvasItem) -> void:
	puede_pausar = true
	# 1. Guardamos las referencias locales de la escena recién cargada
	entorno_actual = entorno
	filtro_vhs_actual = filtro_vhs
	
	# 2. Aplicamos la configuración guardada matemáticamente a la escena física
	if entorno_actual:
		entorno_actual.adjustment_brightness = brillo_global
		entorno_actual.adjustment_contrast = contraste_global
		
	if filtro_vhs_actual:
		filtro_vhs_actual.visible = vhs_activado_global
		
	# 3. Sincronizamos la Interfaz Gráfica del menú de pausa con la realidad
	if boton_vhs:
		boton_vhs.text = "VHS: ON" if vhs_activado_global else "VHS: OFF"
	if slider_brillo:
		slider_brillo.value = brillo_global
	if slider_contraste:
		slider_contraste.value = contraste_global
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausar") and puede_pausar: 
		_alternar_pausa()

func _alternar_pausa() -> void:
	var nuevo_estado: bool = not get_tree().paused
	get_tree().paused = nuevo_estado
	
	if nuevo_estado:
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# --- LÓGICA DE NAVEGACIÓN ---

func _on_volver_al_menu_presionado() -> void:
	get_tree().paused = false
	# 1. Ocultamos el menú de pausa para que no viaje al Menú Principal
	hide() 
	# 2. Cerramos el candado para que el ESC deje de funcionar en el Menú Principal
	puede_pausar = false 
	# 3. Nos aseguramos de que el ratón esté visible para poder hacer clic en el cubo
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var ruta_menu_principal = "res://ui/main_menu/main_menu.tscn"
	get_tree().change_scene_to_file(ruta_menu_principal)
	
# --- RECEPTORES DE SEÑALES DE AUDIO ---

func _on_slider_musica_cambiado(valor: float) -> void:
	musica_global = valor
	var bus_musica = AudioServer.get_bus_index("Musica")
	if bus_musica != -1:
		AudioServer.set_bus_volume_db(bus_musica, linear_to_db(musica_global))
	guardar_configuracion() # Escribe en disco

func _on_slider_fx_cambiado(valor: float) -> void:
	fx_global = valor
	var bus_fx = AudioServer.get_bus_index("FX")
	if bus_fx != -1:
		AudioServer.set_bus_volume_db(bus_fx, linear_to_db(fx_global))
	guardar_configuracion() # Escribe en disco

func _on_slider_brillo_cambiado(valor: float) -> void:
	brillo_global = valor 
	if entorno_actual:
		entorno_actual.adjustment_brightness = brillo_global
	guardar_configuracion() # Escribe en disco

func _on_slider_contraste_cambiado(valor: float) -> void:
	contraste_global = valor 
	if entorno_actual:
		entorno_actual.adjustment_contrast = contraste_global
	guardar_configuracion() # Escribe en disco

func _alternar_vhs() -> void:
	vhs_activado_global = not vhs_activado_global
	
	if filtro_vhs_actual:
		filtro_vhs_actual.visible = vhs_activado_global
		if boton_vhs:
			boton_vhs.text = "VHS: ON" if vhs_activado_global else "VHS: OFF"
			
	guardar_configuracion() # Escribe en disco

# --- SISTEMA DE GUARDADO EN DISCO ---

func guardar_configuracion() -> void:
	var config = ConfigFile.new()
	
	# Categoría "Video"
	config.set_value("Video", "vhs", vhs_activado_global)
	config.set_value("Video", "brillo", brillo_global)
	config.set_value("Video", "contraste", contraste_global)
	
	# Categoría "Audio"
	config.set_value("Audio", "musica", musica_global)
	config.set_value("Audio", "fx", fx_global)
	
	# Escribimos el archivo en el disco duro
	config.save(RUTA_GUARDADO)

func cargar_configuracion() -> void:
	var config = ConfigFile.new()
	
	# Si el archivo no existe (primera vez que juega), abortamos la carga y usamos los valores por defecto
	if config.load(RUTA_GUARDADO) != OK:
		return
		
	# Extraemos los valores (el tercer parámetro es un valor de seguridad por si falla la lectura)
	vhs_activado_global = config.get_value("Video", "vhs", false)
	brillo_global = config.get_value("Video", "brillo", 1.0)
	contraste_global = config.get_value("Video", "contraste", 1.0)
	musica_global = config.get_value("Audio", "musica", 0.7)
	fx_global = config.get_value("Audio", "fx", 0.8)
	
	# Aplicamos el audio inmediatamente a los buses del motor
	var bus_musica = AudioServer.get_bus_index("Musica")
	if bus_musica != -1: AudioServer.set_bus_volume_db(bus_musica, linear_to_db(musica_global))
		
	var bus_fx = AudioServer.get_bus_index("FX")
	if bus_fx != -1: AudioServer.set_bus_volume_db(bus_fx, linear_to_db(fx_global))
	
	# Actualizamos la posición visual de los sliders
	if slider_musica: slider_musica.value = musica_global
	if slider_fx: slider_fx.value = fx_global
	if slider_brillo: slider_brillo.value = brillo_global
	if slider_contraste: slider_contraste.value = contraste_global
	if boton_vhs: boton_vhs.text = "VHS: ON" if vhs_activado_global else "VHS: OFF"
