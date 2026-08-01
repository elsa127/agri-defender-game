extends Control

# --- PRELOAD AUDIO & PATH ---
const GAMEPLAY_SCENE_PATH_1: String = "res://scenes/GamePlay/GamePlay.tscn"
const GAMEPLAY_SCENE_PATH_2: String = "res://scenes/GamePlay/game_play.tscn"

# --- PENYIMPANAN PERMANEN ---
const FILE_KOIN = "user://data_koin.save"
const FILE_LEVEL = "user://data_level.save" # <--- TAMBAHAN BARU UNTUK SAVE LEVEL

# Pemutar audio untuk BGM dan Efek Sentuh
var music_player: AudioStreamPlayer
var audio_player: AudioStreamPlayer

func _ready() -> void:
	print("=== MEMULAI ===")
	
	# 1. SETUP AUDIO
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# 2. HUBUNGKAN NAVIGASI GRUP (Toko, Level, Info)
	var toko_icon = _get_first_texture_button("TokoGroup")
	var level_icon = _get_first_texture_button("LevelGroup")
	var info_icon = _get_first_texture_button("InfoGroup")
	
	if toko_icon:
		if not toko_icon.pressed.is_connected(func(): set_active("toko")):
			toko_icon.pressed.connect(func(): set_active("toko"))
	if level_icon:
		if not level_icon.pressed.is_connected(func(): set_active("level")):
			level_icon.pressed.connect(func(): set_active("level"))
	if info_icon:
		if not info_icon.pressed.is_connected(func(): set_active("info")):
			info_icon.pressed.connect(func(): set_active("info"))
			
	# 3. HUBUNGKAN TOMBOL PENUTUP POP-UP
	var popup_toko = get_node_or_null("TokoHint")
	var popup_info = get_node_or_null("InfoPopup")
	
	var btn_close_toko = _find_close_button(popup_toko, ["CloseButton", "Close", "BtnClose", "Keluar", "X"])
	var btn_close_info = _find_close_button(popup_info, ["CloseInfo", "CloseButton", "Close", "BtnClose", "Keluar", "X"])
	
	if btn_close_toko:
		if not btn_close_toko.pressed.is_connected(_on_close_button_pressed):
			btn_close_toko.pressed.connect(_on_close_button_pressed)
			
	if btn_close_info:
		if not btn_close_info.pressed.is_connected(_on_close_info_pressed):
			btn_close_info.pressed.connect(_on_close_info_pressed)

	# 4. SET AKTIF AWAL KE LEVEL & SEMBUNYIKAN POPUP
	call_deferred("set_active", "level")
	if popup_toko: popup_toko.visible = false
	if popup_info: popup_info.visible = false

	# 5. SINKRONISASI KOIN
	update_tampilan_koin()
	if get_node_or_null("/root/GameManager"):
		if not GameManager.koin_berubah.is_connected(_on_koin_berubah):
			GameManager.koin_berubah.connect(_on_koin_berubah)
			
	# 6. SETUP TOMBOL LEVEL
	var level1_btn = find_child("Level1Button", true, false)
	if level1_btn:
		level1_btn.move_to_front()
	
	# Mencari tombol meskipun namanya Level2But, Level3But, dst
	for i in range(1, 10):
		var btn = find_child("Level" + str(i) + "But*", true, false)
		if not btn: btn = find_child("Level" + str(i) + "Card", true, false)
		
		if btn and btn is TextureButton:
			if not btn.pressed.is_connected(_on_level_button_pressed.bind(i)):
				btn.pressed.connect(_on_level_button_pressed.bind(i))
				
	# 7. Update status gembok/lock level saat scene dimuat
	update_level_status()

func _mainkan_suara_sentuh() -> void:
	if audio_player and audio_player.stream:
		audio_player.play()

# --- PENCARIAN TEXTURE BUTTON & TOMBOL CLOSE ---
func _get_first_texture_button(group_name):
	var group = get_node_or_null(group_name)
	if not group: return null
	for child in group.get_children():
		if child is TextureButton: return child
		var found = _search_in_children(child)
		if found: return found
	return null

func _search_in_children(node):
	for child in node.get_children():
		if child is TextureButton: return child
		var found = _search_in_children(child)
		if found: return found
	return null

func _find_close_button(popup: Node, possible_names: Array) -> BaseButton:
	if not popup: return null
	for n in possible_names:
		var found = popup.find_child(n, true, false)
		if found and found is BaseButton: return found
	return null

# --- PENGATURAN TAMPILAN AKTIF/NORMAL ---
func set_active(which):
	_mainkan_suara_sentuh()
	
	var toko_board_normal = get_node_or_null("TokoGroup/TokoNamePlate/TokoBoardNormal")
	var toko_board_active = get_node_or_null("TokoGroup/TokoNamePlate/TokoBoardActive")
	var level_board_normal = get_node_or_null("LevelGroup/LevelNamePlate/LevelBoardNormal")
	var level_board_active = get_node_or_null("LevelGroup/LevelNamePlate/LevelBoardActive")
	var info_board_normal = get_node_or_null("InfoGroup/InfoNamePlate/InfoBoardNormal")
	var info_board_active = get_node_or_null("InfoGroup/InfoNamePlate/InfoBoardActive")
	
	var popup_toko = get_node_or_null("TokoHint")
	var popup_info = get_node_or_null("InfoPopup")
	
	if toko_board_normal: toko_board_normal.visible = true
	if toko_board_active: toko_board_active.visible = false
	if level_board_normal: level_board_normal.visible = true
	if level_board_active: level_board_active.visible = false
	if info_board_normal: info_board_normal.visible = true
	if info_board_active: info_board_active.visible = false
	if popup_toko: popup_toko.visible = false
	if popup_info: popup_info.visible = false
	
	if which == "toko":
		if toko_board_normal: toko_board_normal.visible = false
		if toko_board_active: toko_board_active.visible = true
		if popup_toko: popup_toko.visible = true
	elif which == "level":
		if level_board_normal: level_board_normal.visible = false
		if level_board_active: level_board_active.visible = true
	elif which == "info":
		if info_board_normal: info_board_normal.visible = false
		if info_board_active: info_board_active.visible = true
		if popup_info: popup_info.visible = true

func _on_toko_icon_pressed() -> void:
	set_active("toko")

func _on_info_icon_pressed() -> void:
	set_active("info")

func _on_close_button_pressed() -> void:
	_mainkan_suara_sentuh()
	var popup_toko = get_node_or_null("TokoHint")
	if popup_toko: popup_toko.visible = false

func _on_close_info_pressed() -> void:
	_mainkan_suara_sentuh()
	var popup_info = get_node_or_null("InfoPopup")
	if popup_info: popup_info.visible = false

# --- FUNGSI UPDATE KOIN ---
func update_tampilan_koin() -> void:
	var total_koin = 0
	if FileAccess.file_exists(FILE_KOIN):
		var file = FileAccess.open(FILE_KOIN, FileAccess.READ)
		if file:
			total_koin = file.get_as_text().to_int()
			file.close()
			if get_node_or_null("/root/GameManager"):
				GameManager.koin_sekarang = total_koin
	elif get_node_or_null("/root/GameManager"):
		total_koin = GameManager.koin_sekarang
		
	var teks_koin_node = _find_coin_label_node()
	if teks_koin_node and teks_koin_node is Label:
		teks_koin_node.text = str(total_koin)

func _on_koin_berubah(koin_baru: int) -> void:
	var teks_koin_node = _find_coin_label_node()
	if teks_koin_node and teks_koin_node is Label:
		teks_koin_node.text = str(koin_baru)

func _find_coin_label_node() -> Node:
	var possible_names = ["TextPoin", "TextKoin", "LabelKoin", "JumlahKoin", "CoinLabel", "LblKoin"]
	for n in possible_names:
		var found = find_child(n, true, false)
		if found: return found
	return null

# =========================================================
# --- PERBAIKAN: BUKA GEMBOK & LABEL HILANG SAAT TERBUKA ---
# =========================================================
func update_level_status() -> void:
	var unlocked = 1
	
	# 1. BACA DATA LEVEL DARI PENYIMPANAN HP
	if FileAccess.file_exists(FILE_LEVEL):
		var file = FileAccess.open(FILE_LEVEL, FileAccess.READ)
		if file:
			unlocked = file.get_as_text().to_int()
			file.close()
			
	# 2. SINKRONKAN KE GAMEMANAGER
	if get_node_or_null("/root/GameManager"):
		if GameManager.unlocked_level > unlocked:
			unlocked = GameManager.unlocked_level
		else:
			GameManager.unlocked_level = unlocked

	# 3. LOOP MENGATUR TOMBOL LEVEL
	for i in range(1, 10):
		# Cari dengan wildcard karena ada tombol "Level2But" dan "Level4Button"
		var level_btn = find_child("Level" + str(i) + "But*", true, false)
		if not level_btn:
			level_btn = find_child("Level" + str(i) + "Card", true, false)
		
		if level_btn:
			var lock_texture = level_btn.find_child("TextureRect", true, false)
			var lock_overlay = level_btn.find_child("LockOverlay", true, false)
			var dark_overlay = level_btn.find_child("DarkOverlay", true, false)
			
			# AMANKAN LABEL ANGKA (Misal: Label2, Label3, TextLevel)
			var label_angka = level_btn.find_child("Label" + str(i), true, false)
			if not label_angka: label_angka = level_btn.find_child("TextLevel", true, false)
			
			if i == 1 or i <= unlocked:
				# --- LEVEL TERBUKA ---
				if level_btn is BaseButton: level_btn.disabled = false
				if lock_texture: lock_texture.visible = false
				if lock_overlay: lock_overlay.visible = false
				if dark_overlay: dark_overlay.visible = false
				
				# SEMBUNYIKAN LABEL GODOT KARENA GAMBAR ASLI SUDAH ADA ANGKA
				if label_angka:
					label_angka.visible = false
			else:
				# --- LEVEL TERKUNCI ---
				if level_btn is BaseButton: level_btn.disabled = true
				if lock_texture: lock_texture.visible = true
				if lock_overlay: lock_overlay.visible = true
				if dark_overlay: dark_overlay.visible = true
				
				# MUNCULKAN LABEL GODOT AGAR TERLIHAT DI ATAS GEMBOK ABU-ABU
				if label_angka:
					label_angka.visible = true

func _on_level_button_pressed(level_num: int) -> void:
	_mainkan_suara_sentuh()
	
	# Selalu baca data dari memori HP saat tombol ditekan
	var unlocked = 1
	if FileAccess.file_exists(FILE_LEVEL):
		var file = FileAccess.open(FILE_LEVEL, FileAccess.READ)
		if file:
			unlocked = file.get_as_text().to_int()
			file.close()
			
	if get_node_or_null("/root/GameManager") and GameManager.unlocked_level > unlocked:
		unlocked = GameManager.unlocked_level

	if level_num <= unlocked:
		if get_node_or_null("/root/GameManager"):
			GameManager.current_level = level_num
		_pindah_ke_gameplay()

func _pindah_ke_gameplay() -> void:
	if not get_tree(): return
	if ResourceLoader.exists(GAMEPLAY_SCENE_PATH_1):
		get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH_1)
	elif ResourceLoader.exists(GAMEPLAY_SCENE_PATH_2):
		get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH_2)
