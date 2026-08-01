extends Control
# --- PRELOAD AUDIO ---

# Path scene Gameplay utama
const GAMEPLAY_SCENE_PATH_1: String = "res://scenes/GamePlay/GamePlay.tscn"
const GAMEPLAY_SCENE_PATH_2: String = "res://scenes/GamePlay/game_play.tscn"
const FILE_KOIN = "user://data_koin.save"

# Pemutar audio untuk BGM dan Efek Sentuh
var music_player: AudioStreamPlayer
var audio_player: AudioStreamPlayer

func _ready() -> void:
	print("=== MEMULAI LEVEL SELECTION ===")
	
	# 1. SETUP MUSIK LATAR (BGM)
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# 2. SETUP EFEK SUARA SENTUH
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# --- SINKRONISASI KOIN ---
	update_tampilan_koin()
	
	if get_node_or_null("/root/GameManager"):
		if not GameManager.koin_berubah.is_connected(_on_koin_berubah):
			GameManager.koin_berubah.connect(_on_koin_berubah)
	# ------------------------
	
	# Pindahkan tombol Level 1 ke layer paling depan jika ada
	var level1_btn = find_child("Level1Button", true, false)
	if level1_btn:
		level1_btn.move_to_front()
	
	# Auto-connect semua tombol level yang ada
	for i in range(1, 10):
		var btn = find_child("Level" + str(i) + "Button", true, false)
		if btn and btn is TextureButton:
			if not btn.pressed.is_connected(_on_level_button_pressed.bind(i)):
				btn.pressed.connect(_on_level_button_pressed.bind(i))
				
	update_level_status()

func _mainkan_suara_sentuh() -> void:
	if audio_player and audio_player.stream:
		audio_player.play()

# --- FUNGSI UPDATE KOIN ---
func update_tampilan_koin() -> void:
	var total_koin = 0
	
	# 1. Ambil dari GameManager jika ada
	if get_node_or_null("/root/GameManager"):
		total_koin = GameManager.koin_sekarang
	else:
		# 2. Fallback baca langsung dari file save koin jika GameManager kosong
		if FileAccess.file_exists(FILE_KOIN):
			var file = FileAccess.open(FILE_KOIN, FileAccess.READ)
			if file:
				total_koin = file.get_as_text().to_int()
				file.close()
	
	# Cari node label koin dengan berbagai kemungkinan nama di scene Level Selection
	var teks_koin_node = _find_coin_label_node()
	if teks_koin_node and teks_koin_node is Label:
		teks_koin_node.text = str(total_koin)

func _on_koin_berubah(koin_baru: int) -> void:
	var teks_koin_node = _find_coin_label_node()
	if teks_koin_node and teks_koin_node is Label:
		teks_koin_node.text = str(koin_baru)

# Helper untuk mencari label koin berdasarkan beberapa nama node umum
func _find_coin_label_node() -> Node:
	var possible_names = ["TextPoin", "TextKoin", "LabelKoin", "JumlahKoin", "CoinLabel", "LblKoin"]
	for n in possible_names:
		var found = find_child(n, true, false)
		if found: return found
	return null

# --- STATUS LEVEL (UNLOCK/LOCK) ---
func update_level_status() -> void:
	var unlocked = 1
	if get_node_or_null("/root/GameManager"):
		unlocked = GameManager.unlocked_level

	for i in range(1, 10):
		var level_btn = _find_level_node(i)
		if level_btn:
			var lock_texture = level_btn.get_node_or_null("TextureRect")
			if not lock_texture: 
				lock_texture = level_btn.find_child("TextureRect", true, false)
			
			if i == 1 or i <= unlocked:
				if level_btn is BaseButton: level_btn.disabled = false
				if lock_texture: lock_texture.visible = false
			else:
				if level_btn is BaseButton: level_btn.disabled = true
				if lock_texture: lock_texture.visible = true

func _on_level_button_pressed(level_num: int) -> void:
	_mainkan_suara_sentuh()
	var unlocked = GameManager.unlocked_level if get_node_or_null("/root/GameManager") else 1
	if level_num <= unlocked:
		GameManager.current_level = level_num
		_pindah_ke_gameplay()

func _pindah_ke_gameplay() -> void:
	if not get_tree(): return
	if ResourceLoader.exists(GAMEPLAY_SCENE_PATH_1):
		get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH_1)
	elif ResourceLoader.exists(GAMEPLAY_SCENE_PATH_2):
		get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH_2)

func _find_level_node(level_num: int) -> Node:
	var node_names = ["Level" + str(level_num) + "Button", "Level" + str(level_num) + "Card", "BtnLevel" + str(level_num), "Level" + str(level_num)]
	for name in node_names:
		var found = get_node_or_null(name)
		if not found: found = find_child(name, true, false)
		if found: return found
	return null

func set_active(which: String) -> void:
	_mainkan_suara_sentuh()

func _on_close_button_pressed() -> void:
	_mainkan_suara_sentuh()

func _on_close_info_pressed() -> void:
	_mainkan_suara_sentuh()
