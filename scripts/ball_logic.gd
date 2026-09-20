extends RigidBody2D

#ANIMATION
@onready var sprite: AnimatedSprite2D = $Sprite2D
var anim_original: String
var camada_nova: AnimatedSprite2D
var mat_antigo: ShaderMaterial
var mat_novo: ShaderMaterial
var trituradores := {}   # triturador -> lentidão
var dono: Node = null    # triturador dono da transição atual
var anim_transicao := ""
var centro_transicao := Vector2.ZERO
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
#EXPLOSION EFFECT
@export var efeito_spawn: PackedScene
#HITSOUND
@export var velocidade_minima := 80.0
@export var velocidade_maxima := 600.0
var _vel_anterior := Vector2.ZERO
#CAMERASHAKE
var _tween_tremor: Tween

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

	#HITSOUND
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_batida)

func _physics_process(_delta: float) -> void:
	_vel_anterior = linear_velocity

func _on_batida(corpo: Node) -> void:
	if not corpo is TileMapLayer or caindo:
		return
	var impacto := _vel_anterior.length()
	if impacto < velocidade_minima:
		return
	SoundControl.hit_wall.pitch_scale = randf_range(0.9, 1.1)
	SoundControl.hit_wall.volume_db = linear_to_db(clampf(impacto / velocidade_maxima, 0.3, 1.0))
	SoundControl.hit_wall.play()

func _spawn_efeito() -> void:
	if efeito_spawn == null:
		return
	var p := efeito_spawn.instantiate() as CPUParticles2D
	get_parent().add_child(p)
	p.global_position = origem
	p.emitting = true
	p.finished.connect(p.queue_free)

func _atualizar_damp() -> void:
	linear_damp = damp_original if trituradores.is_empty() else trituradores.values().max()

func _encerrar_transicao() -> void:
	if dono == null:
		return
	if (global_position - centro_transicao).dot(normal_transicao) > 0.0 and sprite.animation != anim_transicao:
		sprite.play(anim_transicao)
		sprite.set_frame_and_progress(camada_nova.frame, camada_nova.frame_progress)
	dono = null
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
	_tremer_tela()
	await _animar_queda(pos_buraco)
	global_position = origem
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sprite.scale = escala_original
	freeze = false
	sleeping = false
	caindo = false
	sprite.play(anim_original)
	trituradores.clear()
	dono = null
	_atualizar_damp()
	_spawn_efeito()

func next_phase(pos_buraco: Vector2, cena: String, anim_victory: String) -> void:
	if caindo:
		return
	if anim_victory != "" and sprite.animation != anim_victory:
		cair(pos_buraco)
		SoundControl.error.play()
		_piscar_vermelho()
		return
	SoundControl.victory.play()
	await _animar_queda(pos_buraco)
	SceneManager.mudar_cena(cena)

func entrar_triturador(t: Node, lentidao: float, anim_nova: String, centro: Vector2, direcao: Vector2) -> void:
	trituradores[t] = lentidao
	_atualizar_damp()
	_encerrar_transicao()
	if sprite.animation == anim_nova:
		return
	var lado_entrada := 1.0 if (global_position - centro).dot(direcao) > 0.0 else -1.0
	dono = t
	anim_transicao = anim_nova
	centro_transicao = centro
	normal_transicao = -lado_entrada * direcao
	camada_nova.play(anim_nova)
	camada_nova.show()
	for m in [mat_antigo, mat_novo]:
		m.set_shader_parameter("ponto_corte", centro)
		m.set_shader_parameter("normal_corte", normal_transicao)
		m.set_shader_parameter("ativo", true)

func sair_triturador(t: Node) -> void:
	trituradores.erase(t)
	_atualizar_damp()
	if t == dono:
		_encerrar_transicao()

func trocar_sprite(textura: Texture2D) -> void:
	sprite.texture = textura
	var fator := minf(tamanho_original.x / textura.get_size().x, tamanho_original.y / textura.get_size().y)
	sprite.scale = Vector2(fator, fator)

func _usar_nova(nova: bool) -> void:
	sprite.self_modulate.a = 0.0 if nova else 1.0
	camada_nova.visible = nova
	mat_antigo.set_shader_parameter("ativo", false)
	mat_novo.set_shader_parameter("ativo", false)

func _tremer_tela(forca := 80.0, duracao := 0.35) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	if _tween_tremor and _tween_tremor.is_valid():
		_tween_tremor.kill()
	var base := cam.offset
	var passos := 8
	_tween_tremor = create_tween()
	for i in passos:
		var f := forca * (1.0 - float(i) / passos)
		var desvio := Vector2(randf_range(-f, f), randf_range(-f, f))
		_tween_tremor.tween_property(cam, "offset", base + desvio, duracao / passos)
	_tween_tremor.tween_property(cam, "offset", base, 0.03)

func _piscar_vermelho(duracao := 0.5, piscadas := 2, cor := Color(1.0, 0.1, 0.1, 0.45)) -> void:
	var camada := CanvasLayer.new()
	camada.layer = 50
	var rect := ColorRect.new()
	rect.color = cor
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.modulate.a = 0.0
	camada.add_child(rect)
	get_tree().current_scene.add_child(camada)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var pulso := duracao / piscadas
	var t := create_tween()
	for i in piscadas:
		t.tween_property(rect, "modulate:a", 1.0, pulso * 0.3)
		t.tween_property(rect, "modulate:a", 0.0, pulso * 0.7)
	t.tween_callback(camada.queue_free)
