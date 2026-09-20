extends Area2D

@export_enum("idle", "crushed", "pieces") var objective := ""
@export_file("*.tscn") var proxima_fase: String
@export var anim_victory := ""

@onready var sprite: AnimatedSprite2D = $Sprite2D



func _ready() -> void:
	sprite.play(objective)
	body_entered.connect(_on_body_entered)

func _on_body_entered(corpo: Node2D) -> void:
	if corpo.has_method("next_phase"):
		corpo.call_deferred("next_phase", global_position, proxima_fase, anim_victory)
