extends RigidBody2D

#ANIMATION
@onready var sprite: AnimatedSprite2D = $Sprite2D
var anim_original: String
var camada_nova: AnimatedSprite2D
var mat_antigo: ShaderMaterial
var mat_novo: ShaderMaterial
var normal_transicao := Vector2.RIGHT
#PHASES
var origem: Vector2
var caindo := false
#var triturada := false
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
	mat_antigo = sprite.material as ShaderMaterial
	mat_novo = mat_antigo.duplicate()
	mat_antigo.set_shader_parameter("lado", -1.0)
	mat_novo.set_shader_parameter("lado", 1.0)

	camada_nova = sprite.duplicate() as AnimatedSprite2D
	camada_nova.material = mat_novo
	camada_nova.position = Vector2.ZERO
	camada_nova.scale = Vector2.ONE
	sprite.add_child(camada_nova)
	_fim_transicao()

func _fim_transicao() -> void:
	camada_nova.hide()
	mat_antigo.set_shader_parameter("ativo", false)
	mat_novo.set_shader_parameter("ativo", false)

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

func entrar_triturador(lentidao: float, anim_nova: String, centro: Vector2, direcao: Vector2) -> void:
	linear_damp = lentidao
	if sprite.animation == anim_nova:
		return
	var lado_entrada := 1.0 if (global_position - centro).dot(direcao) > 0.0 else -1.0
	normal_transicao = -lado_entrada * direcao
	camada_nova.play(anim_nova)
	camada_nova.show()
	for m in [mat_antigo, mat_novo]:
		m.set_shader_parameter("ponto_corte", centro)
		m.set_shader_parameter("normal_corte", normal_transicao)
		m.set_shader_parameter("ativo", true)

func sair_triturador(anim_nova: String, centro: Vector2) -> void:
	linear_damp = damp_original
	if (global_position - centro).dot(normal_transicao) > 0.0 and sprite.animation != anim_nova:
		sprite.play(anim_nova)
		sprite.set_frame_and_progress(camada_nova.frame, camada_nova.frame_progress)
	_fim_transicao()

func trocar_sprite(textura: Texture2D) -> void:
	sprite.texture = textura
	var fator := minf(tamanho_original.x / textura.get_size().x, tamanho_original.y / textura.get_size().y)
	sprite.scale = Vector2(fator, fator)

func _usar_nova(nova: bool) -> void:
	sprite.self_modulate.a = 0.0 if nova else 1.0
	camada_nova.visible = nova
	mat_antigo.set_shader_parameter("ativo", false)
	mat_novo.set_shader_parameter("ativo", false)
