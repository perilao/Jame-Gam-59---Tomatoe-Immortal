extends CanvasLayer

@onready var left_hand: AnimatedSprite2D = $LeftHand
@onready var right_hand: AnimatedSprite2D = $RightHand

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate_left"):
		_reiniciar(false)
	elif event.is_action_pressed("rotate_right"):
		_reiniciar(true)

func _reiniciar(de_tras: bool) -> void:
	for mao in [left_hand, right_hand]:
		mao.stop()
		if de_tras:
			mao.set_frame_and_progress(mao.sprite_frames.get_frame_count("turn") - 1, 1.0)
			mao.play_backwards("turn")
		else:
			mao.set_frame_and_progress(0, 0.0)
			mao.play("turn")
