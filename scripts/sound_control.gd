extends Node

@onready var victory: AudioStreamPlayer = $victory
@onready var defeat: AudioStreamPlayer = $defeat
@onready var crush: AudioStreamPlayer = $crush
@onready var cut: AudioStreamPlayer = $cut
@onready var hit_wall: AudioStreamPlayer = $hit_wall
@onready var error: AudioStreamPlayer = $error
@onready var heal: AudioStreamPlayer = $heal
@onready var background_music: AudioStreamPlayer = $background_music

func _ready() -> void:
	SoundControl.background_music.play()
