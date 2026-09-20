extends Area2D

@export_enum("obj1", "obj2", "obj3") var tipo := "obj1"

@export var lentidao := 6.0
@export var direcao := Vector2.RIGHT
@export var anim_nova := "crushed"
@onready var sprite: AnimatedSprite2D = $Sprite2D


func _ready() -> void:
	sprite.play(tipo)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(corpo: Node2D) -> void:
	if corpo.has_method("entrar_triturador"):
		corpo.call_deferred("entrar_triturador", self, lentidao, anim_nova, global_position, direcao)
		if tipo == "obj1":
			SoundControl.crush.play()
		if tipo == "obj2":
			SoundControl.cut.play()
		#if tipo == "obj3":
			#SoundControl..play()


func _on_body_exited(corpo: Node2D) -> void:
	if corpo.has_method("sair_triturador"):
		corpo.call_deferred("sair_triturador", self)
