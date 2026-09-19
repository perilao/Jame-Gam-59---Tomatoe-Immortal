extends CanvasLayer

@onready var anim: AnimationPlayer = $TransitionAnimation
var ocupada := false

func _ready() -> void:
	layer = 100
	anim.play_backwards("transition_out")   # revela a primeira cena do jogo

func mudar_cena(caminho: String) -> void:
	if ocupada:
		return
	ocupada = true
	anim.play("transition_out")   # cobre a tela
	await anim.animation_finished
	get_tree().change_scene_to_file(caminho)
	await get_tree().process_frame
	await get_tree().process_frame
	anim.play_backwards("transition_out")             # revela a nova cena
	await anim.animation_finished
	ocupada = false
