extends RichTextLabel

@export var text_speed: float = 0.05  # Kecepatan muncul per karakter
var full_text: String = ""

func _ready():
	full_text = "Di sebuah desa pertanian yang subur, para petani menggantungkan hidup dari hasil sawah dan kebun mereka. "
	visible_characters = 0
	await start_typewriter()

func start_typewriter():
	for i in range(full_text.length()):
		visible_characters = i + 1
		await get_tree().create_timer(text_speed).timeout
