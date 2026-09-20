extends Node2D

@export var camera: Camera2D
@export var velocidade_rotacao := 8.0
@onready var ball: RigidBody2D = $"../Ball"


var angulo_alvo := 0.0  # rotação aparente do labirinto

func _ready() -> void:
	camera.ignore_rotation = false
	#camera.zoom = Vector2(1.5, 1.5)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("rotate_left"):
		girar(-90)
	if Input.is_action_just_pressed("rotate_right"):
		girar(90)

	camera.rotation = lerp_angle(camera.rotation, -angulo_alvo, 1.0 - exp(-velocidade_rotacao * delta))
	#camera.global_position = ball.global_position

func girar(graus: float) -> void:
	angulo_alvo += deg_to_rad(graus)
	var espaco := get_viewport().find_world_2d().space
	PhysicsServer2D.area_set_param(espaco, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2.DOWN.rotated(-angulo_alvo))
