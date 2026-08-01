extends Node

var music_player: AudioStreamPlayer
const BG_MUSIC = preload("res://sound/bg_music.mp3")

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = BG_MUSIC
	music_player.play()
