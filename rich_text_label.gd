extends RichTextLabel

@export var text_speed: float = 0.2  # Kecepatan muncul per karakter (sudah diperlambat)

func _ready():
	# Ambil teks yang sudah kamu ketik di Inspector
	var full_text = text
	visible_characters = 0
	await start_typewriter()

func start_typewriter():
	for i in range(text.length()):
		visible_characters = i + 1
		await get_tree().create_timer(text_speed).timeout
