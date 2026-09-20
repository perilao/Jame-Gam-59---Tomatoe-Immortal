extends Control

@export_file("*.tscn") var prox_cena: String

func _on_texture_button_pressed() -> void:
	SceneManager.mudar_cena(prox_cena)
