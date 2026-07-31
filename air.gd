# File: res://scenes/GamePlay/air_animasi.gd
extends Node2D

@onready var color_rect = $ColorRect
var tween_aliran: Tween

func _ready():
	if color_rect:
		color_rect.modulate.a = 0.0

func munculkan_air(durasi: float = 0.3):
	show()
	
	if color_rect:
		var tween_fade = create_tween()
		tween_fade.tween_property(color_rect, "modulate:a", 0.85, durasi)
		
		if tween_aliran and tween_aliran.is_running():
			tween_aliran.kill()
			
		tween_aliran = create_tween().set_loops()
		tween_aliran.tween_property(color_rect, "scale", Vector2(1.08, 1.08), 0.4).set_trans(Tween.TRANS_SINE)
		tween_aliran.tween_property(color_rect, "scale", Vector2(0.95, 0.95), 0.4).set_trans(Tween.TRANS_SINE)

func sembunyikan_air(durasi: float = 0.2):
	if tween_aliran and tween_aliran.is_running():
		tween_aliran.kill()
		
	if color_rect:
		var tween = create_tween()
		tween.tween_property(color_rect, "modulate:a", 0.0, durasi)
		await tween.finished
	hide()
