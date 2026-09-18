extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(corpo: Node2D) -> void:
	if corpo.has_method("cair"):
		corpo.call_deferred("cair", global_position)
