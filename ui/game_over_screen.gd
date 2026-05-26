extends Node3D

var ruta_menu_principal = "res://ui/main_menu/main_menu.tscn"
var ruta_nivel1 = "res://level/3d_cabin/nivel_1.tscn"

func _on_try_again_button_pressed() -> void:
	get_tree().change_scene_to_file(ruta_nivel1)

func _on_salir_button_pressed() -> void:
	get_tree().change_scene_to_file(ruta_menu_principal)
