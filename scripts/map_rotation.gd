extends Node2D

@export var camera: Camera2D
@export var velocidade_rotacao := 8.0
@onready var ball: RigidBody2D = $"../Ball"

@export var zoom_pulo := 1.08
var zoom_base := Vector2.ONE
var _tween_zoom: Tween

var angulo_alvo := 0.0  # rotação aparente do labirinto

@onready var mapa: TileMapLayer = $TileMapLayer

func _ready() -> void:
	camera.ignore_rotation = false
	_centralizar_camera()
	zoom_base = camera.zoom
	#camera.zoom = Vector2(1.5, 1.5)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("rotate_left"):
		girar(-90)
	if Input.is_action_just_pressed("rotate_right"):
		girar(90)
	
	camera.rotation = lerp_angle(camera.rotation, -angulo_alvo, 1.0 - exp(-velocidade_rotacao * delta))
	#camera.global_position = ball.global_position

func _centralizar_camera() -> void:
	var r := mapa.get_used_rect()
	var centro := (Vector2(r.position) + Vector2(r.size) / 2.0) * Vector2(mapa.tile_set.tile_size)
	camera.global_position = mapa.to_global(centro)
	camera.reset_smoothing()

func girar(graus: float) -> void:
	angulo_alvo += deg_to_rad(graus)
	var espaco := get_viewport().find_world_2d().space
	PhysicsServer2D.area_set_param(espaco, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2.DOWN.rotated(-angulo_alvo))
	
	if _tween_zoom and _tween_zoom.is_valid():
		_tween_zoom.kill()
	_tween_zoom = create_tween()
	_tween_zoom.tween_property(camera, "zoom", zoom_base * zoom_pulo, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_zoom.tween_property(camera, "zoom", zoom_base, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
