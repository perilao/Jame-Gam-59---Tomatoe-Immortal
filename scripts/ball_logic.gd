extends RigidBody2D

#ANIMATION
@onready var sprite: AnimatedSprite2D = $Sprite2D
var anim_original: String

var origem: Vector2
var caindo := false
var escala_original: Vector2
#CRUSHER
var damp_original := 0.0
var textura_original: Texture2D
var tamanho_original: Vector2

func _ready() -> void:
	origem = global_position
	escala_original = sprite.scale
	damp_original = linear_damp
	anim_original = sprite.animation
	#tamanho_original = sprite.texture.get_size() * sprite.scale
func _animar_queda(pos_buraco: Vector2) -> void:
	caindo = true
	freeze = true
	var t := create_tween().set_parallel()
	t.tween_property(self, "global_position", pos_buraco, 0.3)
	t.tween_property(sprite, "scale", Vector2.ZERO, 0.3)
	await t.finished

func cair(pos_buraco: Vector2) -> void:
	if caindo:
		return
	await _animar_queda(pos_buraco)
	global_position = origem
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sprite.scale = escala_original
	freeze = false
	sleeping = false
	caindo = false
	sprite.play(anim_original)
	linear_damp = damp_original

func next_phase(pos_buraco: Vector2, cena: String) -> void:
	if caindo:
		return
	await _animar_queda(pos_buraco)
	get_tree().change_scene_to_file(cena)

func entrar_triturador(lentidao: float) -> void:
	linear_damp = lentidao
	

func sair_triturador(anim_nova: String) -> void:
	linear_damp = damp_original
	sprite.play(anim_nova)

func trocar_sprite(textura: Texture2D) -> void:
	sprite.texture = textura
	var fator := minf(tamanho_original.x / textura.get_size().x, tamanho_original.y / textura.get_size().y)
	sprite.scale = Vector2(fator, fator)
