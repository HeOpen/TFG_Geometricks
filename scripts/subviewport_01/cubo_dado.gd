extends Node3D

var rotaciones_caras = {
	"cara1": Vector3(0, 0, 0),
	"cara2": Vector3(0, -90, 0),
	"cara3": Vector3(0, 90, 0),
	"cara4": Vector3(0, 180, 0),
	"cara5": Vector3(90, 0, 0),
	"cara6": Vector3(-90, 0, 0)
}

func girar_a_cara(nombre_cara: String):
	if not rotaciones_caras.has(nombre_cara): return
	var objetivo_euler = rotaciones_caras[nombre_cara]

	var cuaternion_objetivo = Quaternion.from_euler(Vector3(
		deg_to_rad(objetivo_euler.x),
		deg_to_rad(objetivo_euler.y),
		deg_to_rad(objetivo_euler.z)
	))

	var tween = create_tween()
	tween.tween_property(self, "quaternion", cuaternion_objetivo, 0.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
