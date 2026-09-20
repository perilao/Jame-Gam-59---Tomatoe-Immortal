extends TextureRect

@export var distancia := 300.0
@export var duracao := 0.8
@export var amplitude := 10.0
@export var periodo := 2.0

func _ready() -> void:
	offset_transform_enabled = true
	modulate.a = 0.0
	offset_transform_position.y = -distancia
	_animar()

func _animar() -> void:
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "offset_transform_position:y", 0.0, duracao)
	t.tween_property(self, "modulate:a", 1.0, duracao * 0.5)
	await t.finished
	_flutuar()

func _flutuar() -> void:
	var f := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	f.tween_property(self, "offset_transform_position:y", -amplitude, periodo / 2.0)
	f.tween_property(self, "offset_transform_position:y", amplitude, periodo / 2.0)
