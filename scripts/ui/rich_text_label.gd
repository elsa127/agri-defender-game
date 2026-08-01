extends RichTextLabel

@export var text_speed: float = 0.1 # Waktu ketik per huruf
@export var page_delay: float = 2.0  # Jeda baca (detik) sebelum pindah otomatis

@onready var background_texture = get_node_or_null("../../TextureRect")
@onready var lala_character = get_node_or_null("../../LalaCharacter")

# Pemutar audio untuk narasi cerita
var voice_player: AudioStreamPlayer

# --- VARIABEL PENYIMPANAN STORY ---
const FILE_STORY = "user://story_seen.save"
# ----------------------------------

var story_pages = [
	{
		"background": preload("res://asset_gambar/background/bg_cerita1.png"),
		"text": "Di sebuah desa pertanian yang subur, para petani menggantungkan hidup dari hasil sawah dan kebun mereka.",
		"show_lala": false,
		"voice": preload("res://sound/story_1.MP3") # Sesuaikan path foldernya
	},
	{
		"background": preload("res://asset_gambar/background/bg_cerita2.png"),
		"text": "Namun, cuaca mulai berubah. Suhu tidak stabil, tanah cepat kering, dan air tidak lagi mengalir merata ke tanaman.",
		"show_lala": false,
		"voice": preload("res://sound/story_2.MP3")
	},
	{
		"background": preload("res://asset_gambar/background/bg_cerita2.png"),
		"text": "Sekarang giliranmu membantu LALA. Sambungkan pipa, alirkan air ke tanaman, dan atur suhu agar panen berhasil!",
		"show_lala": true,
		"voice": preload("res://sound/story_3.MP3")
	},
	{
		"background": preload("res://asset_gambar/background/bg_cerita2.png"),
		"text": "LALA, asisten pertanian pintar, membawa sistem irigasi dan sensor lingkungan untuk menyelamatkan tanaman.",
		"show_lala": true,
		"voice": preload("res://sound/story_4.MP3")
	}
]

var current_page = 0
var active_tween: Tween

func _ready():
	# --- CEK APAKAH STORY SUDAH PERNAH DILIHAT SEBELUMNYA ---
	if FileAccess.file_exists(FILE_STORY):
		# Langsung pindah ke level selection tanpa memuat apapun
		get_tree().change_scene_to_file("res://scenes/level_selection.tscn")
		return
	# --------------------------------------------------------
	
	# 1. Setup AudioStreamPlayer secara dinamis
	voice_player = AudioStreamPlayer.new()
	add_child(voice_player)
	
	# Menaikkan volume audio (dalam satuan desibel, misal +5 dB agar lebih kencang)
	voice_player.volume_db = 5.0 
	
	load_page(0)

func load_page(page_index: int):
	# Jika semua halaman sudah selesai, simpan data dan pindah scene
	if page_index >= story_pages.size():
		# --- SIMPAN DATA BAHWA STORY SUDAH SELESAI ---
		var file = FileAccess.open(FILE_STORY, FileAccess.WRITE)
		if file:
			file.store_string("sudah_baca")
			file.close()
		# ---------------------------------------------
		
		get_tree().change_scene_to_file("res://scenes/level_selection.tscn")
		return

	var page = story_pages[page_index]

	# Update visual
	if background_texture:
		background_texture.texture = page.background
	if lala_character:
		lala_character.visible = page.show_lala

	# Putar audio narasi sesuai halaman
	if page.has("voice") and page.voice:
		voice_player.stream = page.voice
		voice_player.play()

	# Set teks awal
	text = page.text
	visible_ratio = 0.0

	# Hentikan tween lama jika ada
	if active_tween and active_tween.is_running():
		active_tween.kill()

	# Jalankan animasi ketik menggunakan Tween
	var total_time = text.length() * text_speed
	active_tween = create_tween()
	
	# 1. Ketik teks secara mulus
	active_tween.tween_property(self, "visible_ratio", 1.0, total_time)
	
	# 2. Beri jeda waktu baca
	active_tween.tween_interval(page_delay)
	
	# 3. Otomatis lanjut ke halaman berikutnya setelah jeda selesai
	active_tween.tween_callback(func():
		current_page += 1
		load_page(current_page)
	)

# Fitur opsional: jika diklik/tap saat mengetik, langsung tampilkan penuh & langsung tunggu jeda
func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		if active_tween and active_tween.is_running():
			# Mempercepat animasi ketik langsung ke selesai
			visible_ratio = 1.0
