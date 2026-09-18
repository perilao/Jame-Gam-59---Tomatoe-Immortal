extends Area2D

@export var lentidao := 6.0
@export var sprite_novo: Texture2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(corpo: Node2D) -> void:
	if corpo.has_method("entrar_triturador"):
		corpo.call_deferred("entrar_triturador", lentidao)

func _on_body_exited(corpo: Node2D) -> void:
	if corpo.has_method("sair_triturador"):
		corpo.call_deferred("sair_triturador", sprite_novo)
