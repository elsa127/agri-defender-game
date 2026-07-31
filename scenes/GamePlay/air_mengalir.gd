extends Node2D

@onready var color_rect = $ColorRect
var tween_aliran: Tween

func _ready():
	if color_rect:
		color_rect.modulate.a = 0.0
	else:
		print("❌ ColorRect tidak ditemukan!")

func munculkan_air(durasi: float = 0.3):
	print("💧 munculkan_air() dipanggil!")
	show()
	
	if color_rect:
		color_rect.visible = true
		var tween_fade = create_tween()
		tween_fade.tween_property(color_rect, "modulate:a", 0.85, durasi)
		
		if tween_aliran and tween_aliran.is_running():
			tween_aliran.kill()
			
		tween_aliran = create_tween().set_loops()
		tween_aliran.tween_property(color_rect, "scale", Vector2(1.05, 1.05), 0.5)
		tween_aliran.tween_property(color_rect, "scale", Vector2(1.0, 1.0), 0.5)
		print("✨ Animasi berjalan!")
	else:
		print("❌ ColorRect null!")

func sembunyikan_air(durasi: float = 0.2):
	if tween_aliran and tween_aliran.is_running():
		tween_aliran.kill()
		
	if color_rect:
		var tween = create_tween()
		tween.tween_property(color_rect, "modulate:a", 0.0, durasi)
		await tween.finished
	hide()
