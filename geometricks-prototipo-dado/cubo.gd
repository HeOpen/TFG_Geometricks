extends Node3D

# Mantenemos tu diccionario en grados porque es más fácil de leer para nosotros
var rotaciones_caras = {
	"cara1": Vector3(0, 0, 0),      # Verde
	"cara2": Vector3(0, -90, 0),    # Roja
	"cara3": Vector3(0, 90, 0),     # Azul
	"cara4": Vector3(0, 180, 0),    # Rosa
	"cara5": Vector3(90, 0, 0),     # Amarilla
	"cara6": Vector3(-90, 0, 0)     # Naranja
}

func girar_a_cara(nombre_cara: String):
	if not rotaciones_caras.has(nombre_cara): return
	var objetivo_euler = rotaciones_caras[nombre_cara]
	
	# 1. Los cuaterniones necesitan Radianes, así que convertimos los grados
	var rad_x = deg_to_rad(objetivo_euler.x)
	var rad_y = deg_to_rad(objetivo_euler.y)
	var rad_z = deg_to_rad(objetivo_euler.z)
	var objetivo_rad = Vector3(rad_x, rad_y, rad_z)

	# 2. Creamos el Cuaternión matemático a partir de nuestros ángulos
	var cuaternion_objetivo = Quaternion.from_euler(objetivo_rad)

	# 3. Interpolamos la propiedad "quaternion" directamente
	# Godot aplicará SLERP (camino más corto y suave) automáticamente
	var tween = create_tween()
	tween.tween_property(self, "quaternion", cuaternion_objetivo, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
