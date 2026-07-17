extends RichTextLabel

@export var text_speed: float = 0.2

# Referensi ke node background dan karakter
@onready var background_texture = get_node("../../TextureRect")
@onready var lala_character = get_node("../../LalaCharacter")

# Data untuk setiap halaman story
var story_pages = [
	{
		"background": preload("res://asset_gambar/background/bg_cerita1.png"),  # Halaman 1
		"text": "Di sebuah desa pertanian yang subur, para petani menggantungkan hidup dari hasil sawah dan kebun mereka.",
		"show_lala": false
	},
	{
		"background": preload("res://asset_gambar/background/bg_cerita2.png"),  # Halaman 2
		"text": "Namun, cuaca mulai berubah. Suhu tidak stabil, tanah cepat kering, dan air tidak lagi mengalir merata ke tanaman.",
		"show_lala": false
	},
	{
		"background": preload("res://asset_gambar/background/bg_cerita2.png"),  # Halaman 3
		"text": "Sekarang giliranmu membantu LALA. Sambungkan pipa, alirkan air ke tanaman, dan atur suhu agar panen berhasil!",
		"show_lala": true
	},
	{
		"background": preload("res://asset_gambar/background/bg_cerita2.png"),  # Halaman 4
		"text": "LALA, asisten pertanian pintar, membawa sistem irigasi dan sensor lingkungan untuk menyelamatkan tanaman.",
		"show_lala": true
	}
]

var current_page = 0
var is_typing = true

func _ready():
	load_page(0)

func load_page(page_index):
	if page_index < story_pages.size():
		var page = story_pages[page_index]
		
		# Ganti background
		if background_texture:
			background_texture.texture = page.background
		
		# Show/Hide karakter LALA
		if lala_character:
			lala_character.visible = page.show_lala
		
		# Tampilkan teks dengan efek typewriter
		text = page.text
		visible_characters = 0
		is_typing = true
		await start_typewriter()
		is_typing = false
	else:
		# Semua halaman selesai, pindah ke MainMenu
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func start_typewriter():
	for i in range(text.length()):
		visible_characters = i + 1
		await get_tree().create_timer(text_speed).timeout

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		if is_typing:
			# Skip animasi ketik
			visible_characters = -1
			is_typing = false
		else:
			# Lanjut ke halaman berikutnya
			current_page += 1
			load_page(current_page)
