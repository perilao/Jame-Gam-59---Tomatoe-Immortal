extends TextureButton

class_name AnimatedButton

const REST_SCALE := Vector2.ONE
const HOVER_SCALE := Vector2(1.1, 1.1)
const SQUASH_SCALE := Vector2(1.15, 0.9)

const HOVER_TIME := 0.2
const SQUASH_TIME := 0.1
var _tween: Tween = null

@export var distancia := 80.0
@export var duracao := 0.6

func _ready() -> void:
	offset_transform_enabled = true # offset_transform_* props do nothing without this
	mouse_entered.connect(_on_anim_button_mouse_entered)
	mouse_exited.connect(_on_anim_button_mouse_exited)
	button_down.connect(_on_anim_button_button_down)
	_animar_entrada()

func _animar_entrada() -> void:
	modulate.a = 0.0
	offset_transform_position.y = distancia

	var t := create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "offset_transform_position:y", 0.0, duracao)
	t.tween_property(self, "modulate:a", 1.0, duracao * 0.6)

func _restart_tween() -> Tween:
	if _tween and _tween.is_valid():
		_tween.kill() # drop old anim so tweens dont fight
	_tween = create_tween()
	return _tween

func _on_anim_button_mouse_entered() -> void:
	_restart_tween().tween_property(self, ^"offset_transform_scale", HOVER_SCALE, HOVER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_anim_button_mouse_exited() -> void:
	_restart_tween().tween_property(self, ^"offset_transform_scale", REST_SCALE, HOVER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_anim_button_button_down() -> void:
	var tween: Tween = _restart_tween()
	tween.tween_property(self, ^"offset_transform_scale", SQUASH_SCALE, SQUASH_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, ^"offset_transform_scale", HOVER_SCALE, HOVER_TIME).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
