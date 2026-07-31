extends Node2D

@export var gambar_level_1: Texture2D
@export var gambar_level_2: Texture2D
@export var gambar_level_3: Texture2D

# --- VARIABEL BACKGROUND FUN FACT ---
@onready var bg_funfact_1 = preload("res://asset_gambar/gambar_board/funfact_padi.png")
@onready var bg_funfact_2 = preload("res://asset_gambar/gambar_board/funfact_tomat.png")
@onready var bg_funfact_3 = preload("res://asset_gambar/gambar_board/funfact_jagung.png")
# ------------------------------------

@onready var gambar_musik_hidup = preload("res://asset_gambar/gambar_button/button_musik_hidup.png")
@onready var gambar_musik_mati = preload("res://asset_gambar/gambar_button/button_musik_mati.png")

const PIPA_LURUS = preload("res://scenes/scene_pipa/pipa_lurus.tscn")
const PIPA_SIKU = preload("res://scenes/scene_pipa/pipa_siku.tscn")
const PIPA_T = preload("res://scenes/scene_pipa/pipa_t.tscn")
const PIPA_X = preload("res://scenes/scene_pipa/pipa_x.tscn")
const VALVE = preload("res://scenes/scene_pipa/solenoid_valve.tscn")
const SOIL = preload("res://scenes/tanaman/tanahkosong.tscn")
const TANAMAN = preload("res://scenes/tanaman/tanaman.tscn")

var daftar_tanaman: Array = []

var grid_pixel_size = 135
var grid_offset = Vector2(190, 440)

# ==========================================
# TOMBOL SAKTI UNTUK TESTING
# ==========================================
var mode_debug: bool = true
# ==========================================

var seed_level_ini: int = 0

# ==========================================
# VARIABEL SISTEM HINT 3 TAHAP
# ==========================================
var sisa_hint: int = 3
var tahap_hint: int = 0 

# ==========================================================
# VARIABEL SISTEM TUTORIAL INTERAKTIF (MULTI-HOLE SUPPORT)
# ==========================================================
var indeks_dialog_lala: int = 0         
var tutorial_sudah_selesai: bool = false
const FILE_TUTORIAL = "user://tutorial_lala.save"
const FILE_KOIN = "user://data_koin.save"           
var daftar_dialog_lala: Array = [
	{
		"teks": "Halo! Aku Lala. Ini adalah sawah padi pertama yang harus kita bantu. Lihat sumber air di sebelah kiri.",
		"fokus": Vector4(10, 330, 280, 280) 
	},
	{
		"teks": "Semua tanaman harus mendapatkan air, kelembapan, dan suhu harus sesuai target agar padi bisa tumbuh dengan baik.",
		"fokus": Vector4(10, 330, 280, 280) 
	},
	{
		"teks": "Lihat sumber air di sebelah kiri. Air harus mengalir dari sana menuju tanaman padi.",
		"fokus": Vector4(10, 330, 140, 140) 
	},
	{
		"teks": "Coba ketuk pipa ini untuk memutar arahnya ke tanaman padi!",
		"fokus": Vector4(145, 330, 143, 143) 
	},
	{
		"teks": "Selain air, suhu dan kelembapan juga penting untuk pertumbuhan padi.",
		"fokus": Vector4(0, 0, 0, 0) 
	},
	{
		"teks": "Coba lihat panel di atas! Ini adalah pengatur Kelembaban. Padi sangat suka lingkungan yang pas, tidak boleh terlalu kering ataupun terlalu basah.",
		"fokus": Vector4(95, 245, 190, 70) 
	},
	{
		"teks": "Perhatikan panel suhu di kanan. Geser pengatur kelembapan di atas sampai suhu berada di area target.",
		"fokus_array": [
			Vector4(95, 245, 190, 70),  
			Vector4(329, 340, 75, 295) 
		]
	},
	{
		"teks": "Kalau kamu bingung, tekan tombol Hint untuk mendapatkan petunjuk.",
		"fokus": Vector4(177, 645, 80, 50) 
	},
	{
		"teks": "Selamat bermain....",
		"fokus": Vector4(0, 0, 0, 0) 
	}
]
# ==========================================================

const DATA_LEVEL = {
	1: {
		"nama_tanaman": "Padi",
		"fun_fact": "Padi sebenarnya adalah jenis rumput raksasa yang sudah dibudidayakan manusia sejak ribuan tahun lalu!",
		"path_gambar": "res://asset_gambar/gambar_tanaman/padi_hint.png",
		"ukuran_grid": "2x2",
		"target_suhu": 30,
		"target_kelembapan": 60,
		"min_kelembapan": 60,
		"max_kelembapan": 70,
		"suhu_awal": 45,
		"kelembapan_awal": 20,
		"pipes": [
			{"x": 0, "y": 0, "jenis": "VALVE", "rotasi": 0},
			{"x": 1, "y": 0, "jenis": "SIKU", "rotasi": 0},
			{"x": 0, "y": 1, "jenis": "SOIL", "rotasi": 0},
			{"x": 1, "y": 1, "jenis": "TANAMAN", "rotasi": 0}
		]
	},
	2: {
		"nama_tanaman": "Tomat Ceri",
		"fun_fact": "Tomat secara ilmiah adalah buah! Tapi di dunia perdagangan, tomat sempat resmi dianggap sebagai sayur.",
		"path_gambar": "res://asset_gambar/gambar_tanaman/tomat_hint.png",
		"ukuran_grid": "3x3",
		"target_suhu": 28,
		"target_kelembapan": 60,
		"min_kelembapan": 50,
		"max_kelembapan": 65,
		"suhu_awal": 55,
		"kelembapan_awal": 10,
		"pipes": [
			{"x": 0, "y": 0, "jenis": "VALVE", "rotasi": 0},
			{"x": 1, "y": 0, "jenis": "T", "rotasi": 180},
			{"x": 2, "y": 0, "jenis": "TANAMAN", "rotasi": 0},
			{"x": 0, "y": 1, "jenis": "TANAMAN", "rotasi": 0},
			{"x": 1, "y": 1, "jenis": "T", "rotasi": 0},
			{"x": 2, "y": 1, "jenis": "SIKU", "rotasi": 0},
			{"x": 0, "y": 2, "jenis": "TANAMAN", "rotasi": 0},
			{"x": 1, "y": 2, "jenis": "LURUS", "rotasi": 0},
			{"x": 2, "y": 2, "jenis": "SIKU", "rotasi": 90}
		]
	},
	3: {
		"nama_tanaman": "Jagung",
		"fun_fact": "Jumlah biji pada buah jagung selalu bilangan genap. Rambut jagung di atasnya berfungsi untuk menangkap sari!",
		"path_gambar": "res://asset_gambar/gambar_tanaman/jagung_hint.png",
		"ukuran_grid": "4x4",
		"target_suhu": 30,
		"target_kelembapan": 60,
		"min_kelembapan": 40,
		"max_kelembapan": 60,
		"suhu_awal": 60,
		"kelembapan_awal": 0,
		"pipes": [
			{"x": 0, "y": 0, "jenis": "TANAMAN", "rotasi": 0},
			{"x": 1, "y": 0, "jenis": "SOIL", "rotasi": 0},
			{"x": 2, "y": 0, "jenis": "TANAMAN", "rotasi": 0},
			{"x": 3, "y": 0, "jenis": "SOIL", "rotasi": 0},
			
			{"x": 0, "y": 1, "jenis": "SIKU", "rotasi": 180},
			{"x": 1, "y": 1, "jenis": "LURUS", "rotasi": 0},
			{"x": 2, "y": 1, "jenis": "X", "rotasi": 0},
			{"x": 3, "y": 1, "jenis": "SIKU", "rotasi": 0},
			
			{"x": 0, "y": 2, "jenis": "SOIL", "rotasi": 0},
			{"x": 1, "y": 2, "jenis": "SOIL", "rotasi": 0},
			{"x": 2, "y": 2, "jenis": "LURUS", "rotasi": 90},
			{"x": 3, "y": 2, "jenis": "LURUS", "rotasi": 90},
			
			{"x": 0, "y": 3, "jenis": "VALVE", "rotasi": 0},
			{"x": 1, "y": 3, "jenis": "LURUS", "rotasi": 0},
			{"x": 2, "y": 3, "jenis": "SIKU", "rotasi": 90},
			{"x": 3, "y": 3, "jenis": "TANAMAN", "rotasi": 0}
		]
	}
}

var level_sekarang: int = 1
var suhu_saat_ini: int = 0
var kelembapan_saat_ini: int = 0
var level_selesai: bool = false
var koin_sekarang: int = 0
var target_koin: int = 1000
var musik_aktif: bool = true
var simulasi_pipa_tersambung: bool = false
var simulasi_suhu_sudah_pas: bool = false
var simulasi_kelembapan_sudah_pas: bool = false
var debit_air_terpilih: String = "MATI"

func _ready() -> void:
	if mode_debug == false:
		randomize()
		seed_level_ini = randi()
	else:
		seed_level_ini = 12345
		
	# --- CEK APAKAH TUTORIAL PERNAH DISELESAIKAN ---
	if FileAccess.file_exists(FILE_TUTORIAL):
		tutorial_sudah_selesai = true
		
	# --- MUAT DATA KOIN PEMAIN ---
	if FileAccess.file_exists(FILE_KOIN):
		var file_koin = FileAccess.open(FILE_KOIN, FileAccess.READ)
		if file_koin:
			koin_sekarang = file_koin.get_as_text().to_int()
			file_koin.close()
			
	# --- PAKSA MUSIK NYALA & LOOPING OTOMATIS ---
	var bg_music = get_node_or_null("BgMusic")
	if bg_music:
		if not bg_music.playing:
			bg_music.play()
		if not bg_music.finished.is_connected(bg_music.play):
			bg_music.finished.connect(bg_music.play)
	# ---------------------------------------------
	
	if has_node("InterfaceUI"):
		var parent_ui = $InterfaceUI
		if not parent_ui.has_node("OverlayRedup"):
			var overlay = ColorRect.new()
			overlay.name = "OverlayRedup"
			overlay.color = Color(0, 0, 0, 0.0)
			overlay.visible = false
			overlay.position = Vector2.ZERO
			overlay.size = get_viewport_rect().size
			parent_ui.add_child(overlay)
		
	hubungkan_signal_popup()
	muat_level(level_sekarang)

	# --- SETUP SUARA SLIDER KELEMBAPAN ---
	var slider_kelem = get_node_or_null("InterfaceUI/Kelembapan/SliderKelembapan")
	if slider_kelem:
		if not slider_kelem.drag_started.is_connected(_on_slider_drag_started):
			slider_kelem.drag_started.connect(_on_slider_drag_started)
		if not slider_kelem.drag_ended.is_connected(_on_slider_drag_ended):
			slider_kelem.drag_ended.connect(_on_slider_drag_ended)
	# --------------------------------------------------------------

# ==========================================
# FUNGSI SUARA KLIK GLOBAL (BARU)
# ==========================================
func mainkan_suara_klik() -> void:
	var sfx = get_node_or_null("SfxKlik")
	if sfx:
		sfx.play()
# ==========================================

func hubungkan_signal_popup() -> void:
	var btn_beli = get_node_or_null("InterfaceUI/PapanHintHabis/BtnBeliHint")
	if btn_beli and not btn_beli.pressed.is_connected(_on_btn_beli_hint_pressed):
		btn_beli.pressed.connect(func(): anim_tombol_klik(btn_beli); _on_btn_beli_hint_pressed())
		
	var btn_close_habis = get_node_or_null("InterfaceUI/PapanHintHabis/BtnClose")
	if btn_close_habis and not btn_close_habis.pressed.is_connected(_on_btn_close_hint_habis_pressed):
		btn_close_habis.pressed.connect(func(): anim_tombol_klik(btn_close_habis); _on_btn_close_hint_habis_pressed())

	var btn_close_beli = get_node_or_null("InterfaceUI/PapanBeliHint/BtnClose")
	if btn_close_beli and not btn_close_beli.pressed.is_connected(_on_btn_close_beli_hint_pressed):
		btn_close_beli.pressed.connect(func(): anim_tombol_klik(btn_close_beli); _on_btn_close_beli_hint_pressed())

	var btn_ok_poin = get_node_or_null("InterfaceUI/PapanBeliHint/PoinTidakCukup/BtnOk")
	if btn_ok_poin and not btn_ok_poin.pressed.is_connected(_on_btn_ok_poin_tidak_cukup_pressed):
		btn_ok_poin.pressed.connect(func(): anim_tombol_klik(btn_ok_poin); _on_btn_ok_poin_tidak_cukup_pressed())

	var btn_ok_hint = get_node_or_null("InterfaceUI/papan_hint/buttonOk")
	if btn_ok_hint and not btn_ok_hint.pressed.is_connected(_on_buttonOk_Hint_pressed):
		btn_ok_hint.pressed.connect(func(): anim_tombol_klik(btn_ok_hint); _on_buttonOk_Hint_pressed())

	var btn_close_hint = get_node_or_null("InterfaceUI/papan_hint/BtnClose") 
	if btn_close_hint and not btn_close_hint.pressed.is_connected(_on_buttonOk_Hint_pressed):
		btn_close_hint.pressed.connect(func(): anim_tombol_klik(btn_close_hint); _on_buttonOk_Hint_pressed())

	# --- SETUP KARTU/PAKET HINT ---
	var path_container = "InterfaceUI/PapanBeliHint/HintContainer"
	_setup_tombol_paket(path_container + "/Hint1", 1, 25)
	_setup_tombol_paket(path_container + "/Hint5", 5, 110)
	_setup_tombol_paket(path_container + "/Hint10", 10, 200)
	_setup_tombol_paket(path_container + "/Hint20", 20, 350)

func _setup_tombol_paket(node_path: String, jumlah_hint: int, harga: int) -> void:
	var btn = get_node_or_null(node_path)
	if not btn: return
	
	btn.pivot_offset = btn.size / 2.0
	
	if btn.has_signal("gui_input"):
		for conn in btn.gui_input.get_connections():
			btn.gui_input.disconnect(conn.callable)
			
		btn.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					var tween_press = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
					tween_press.tween_property(btn, "scale", Vector2(0.92, 0.92), 0.08)
				else:
					var tween_release = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
					tween_release.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12)
					_on_paket_clicked(btn, jumlah_hint, harga)
		)

func _on_paket_clicked(btn_node: Control, jumlah_hint: int, harga: int) -> void:
	mainkan_suara_klik() # Suara klik
	if koin_sekarang < harga:
		var pos_asal = btn_node.position
		var tween_gagal = create_tween()
		tween_gagal.tween_property(btn_node, "position", pos_asal + Vector2(-8, 0), 0.04)
		tween_gagal.tween_property(btn_node, "position", pos_asal + Vector2(8, 0), 0.04)
		tween_gagal.tween_property(btn_node, "position", pos_asal, 0.04)
		tampilkan_poin_tidak_cukup()
		return

	_reset_semua_seleksi_paket()

	var border_glow = btn_node.get_node_or_null("SelectionBorder")
	if border_glow: border_glow.visible = true

	var pointer_icon = btn_node.get_node_or_null("PointerIcon")
	if pointer_icon: pointer_icon.visible = true

	var tween_pop = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_pop.tween_property(btn_node, "scale", Vector2(1.06, 1.06), 0.1)

	await get_tree().create_timer(0.25).timeout
	beli_paket_hint(jumlah_hint, harga)

func _reset_semua_seleksi_paket() -> void:
	var path_container = get_node_or_null("InterfaceUI/PapanBeliHint/HintContainer")
	if not path_container: return

	for child in path_container.get_children():
		child.scale = Vector2.ONE
		var border = child.get_node_or_null("SelectionBorder")
		if border: border.visible = false
		var pointer = child.get_node_or_null("PointerIcon")
		if pointer: pointer.visible = false

func tampilkan_poin_tidak_cukup() -> void:
	var node_pop = get_node_or_null("InterfaceUI/PapanBeliHint/PoinTidakCukup")
	var node_papan_beli = get_node_or_null("InterfaceUI/PapanBeliHint")
	
	if not node_pop or not node_papan_beli: return

	var overlay_pop = node_papan_beli.get_node_or_null("OverlayRedupPop")
	if not overlay_pop:
		overlay_pop = ColorRect.new()
		overlay_pop.name = "OverlayRedupPop"
		overlay_pop.color = Color(0, 0, 0, 0.0)
		overlay_pop.mouse_filter = Control.MOUSE_FILTER_STOP 
		node_papan_beli.add_child(overlay_pop)
	
	overlay_pop.position = Vector2.ZERO
	overlay_pop.size = node_papan_beli.size
	overlay_pop.visible = true
	node_papan_beli.move_child(overlay_pop, node_pop.get_index())

	var tween_overlay = create_tween()
	tween_overlay.tween_property(overlay_pop, "color:a", 0.6, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	node_pop.visible = true
	if "pivot_offset" in node_pop:
		node_pop.pivot_offset = node_pop.size / 2.0
	node_pop.scale = Vector2.ZERO
	
	var tween_pop = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_pop.tween_property(node_pop, "scale", Vector2.ONE, 0.25)

func _on_btn_ok_poin_tidak_cukup_pressed() -> void:
	var node_pop = get_node_or_null("InterfaceUI/PapanBeliHint/PoinTidakCukup")
	var node_papan_beli = get_node_or_null("InterfaceUI/PapanBeliHint")

	if node_papan_beli:
		var overlay_pop = node_papan_beli.get_node_or_null("OverlayRedupPop")
		if overlay_pop:
			var tween_overlay = create_tween()
			tween_overlay.tween_property(overlay_pop, "color:a", 0.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			tween_overlay.finished.connect(func(): overlay_pop.visible = false)

	if node_pop:
		var tween_pop = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween_pop.tween_property(node_pop, "scale", Vector2.ZERO, 0.15)
		await tween_pop.finished
		node_pop.visible = false

func anim_tombol_klik(node_tombol: Control) -> void:
	if not node_tombol: return
	
	mainkan_suara_klik() # Suara klik dipanggil secara sentral di sini
	
	node_tombol.pivot_offset = node_tombol.size / 2.0
	var tween = create_tween().set_parallel(false)
	tween.tween_property(node_tombol, "scale", Vector2(0.9, 0.9), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node_tombol, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _process(_delta: float) -> void:
	if level_selesai: return
	simulasi_pipa_tersambung = cek_semua_pipa_tersambung()
	if simulasi_pipa_tersambung and simulasi_suhu_sudah_pas and simulasi_kelembapan_sudah_pas:
		pemicu_menang_level()

func muat_level(nomor_level: int) -> void:
	seed(seed_level_ini)
	if not DATA_LEVEL.has(nomor_level): return
		
	var data = DATA_LEVEL[nomor_level]
	level_selesai = false
	daftar_tanaman.clear()
	tahap_hint = 0
	
	if has_node("PapanSelamat"): $PapanSelamat.visible = false
	if has_node("InterfaceUI/PapanSelamat"): $InterfaceUI/PapanSelamat.visible = false
	if has_node("InterfaceUI/papan_hint"): $InterfaceUI/papan_hint.visible = false
	if has_node("InterfaceUI/PapanHintHabis"): $InterfaceUI/PapanHintHabis.visible = false
	if has_node("InterfaceUI/PapanBeliHint"): 
		$InterfaceUI/PapanBeliHint.visible = false
		if has_node("InterfaceUI/PapanBeliHint/PoinTidakCukup"):
			$InterfaceUI/PapanBeliHint/PoinTidakCukup.visible = false
	
	sembunyikan_overlay_redup()
	perbarui_tampilan_hint()
	perbarui_tampilan_koin()

	for child in $PipeGrid.get_children(): child.queue_free()
	
	if nomor_level == 1 and gambar_level_1: $BoardLv1.texture = gambar_level_1
	elif nomor_level == 2 and gambar_level_2: $BoardLv1.texture = gambar_level_2
	elif nomor_level == 3 and gambar_level_3: $BoardLv1.texture = gambar_level_3
	
	suhu_saat_ini = data["suhu_awal"]
	kelembapan_saat_ini = data["kelembapan_awal"]
	debit_air_terpilih = "MATI"
	
	simulasi_suhu_sudah_pas = (suhu_saat_ini == data["target_suhu"])
	simulasi_kelembapan_sudah_pas = (kelembapan_saat_ini == data["target_kelembapan"])
	
	var node_slider_suhu = get_node_or_null("InterfaceUI/Termometer/SliderSuhu")
	var node_label_target = get_node_or_null("InterfaceUI/Termometer/LblTargetSuhu")
	var node_label_sekarang = get_node_or_null("InterfaceUI/Termometer/LblSuhuSekarang")
	
	if node_slider_suhu:
		node_slider_suhu.value = suhu_saat_ini
		var label_angka = node_slider_suhu.get_node_or_null("LblAngkaSuhu")
		if not label_angka: label_angka = get_node_or_null("InterfaceUI/Termometer/LblAngkaSuhu")
			
		if label_angka:
			label_angka.text = str(suhu_saat_ini) + "°C"
			var suhu_min = 10
			var suhu_max = 60
			var tinggi_slider = node_slider_suhu.size.y
			var rasio_suhu = float(suhu_saat_ini - suhu_min) / float(suhu_max - suhu_min)
			var area_aktif = tinggi_slider - 20
			var posisi_y_lokal = node_slider_suhu.position.y + 10 + (area_aktif * (1.0 - rasio_suhu))
			label_angka.position = Vector2(node_slider_suhu.position.x + 22, posisi_y_lokal - 12)
			
	if node_label_target: node_label_target.text = str(data["target_suhu"]) + "°C"
	if node_label_sekarang: node_label_sekarang.text = str(suhu_saat_ini) + "°C"
			
	if has_node("InterfaceUI/Kelembapan/SliderKelembapan"):
		$"InterfaceUI/Kelembapan/SliderKelembapan".value = kelembapan_saat_ini
		if has_node("InterfaceUI/Kelembapan/SliderKelembapan/LblAngkaKelembapan"):
			$"InterfaceUI/Kelembapan/SliderKelembapan/LblAngkaKelembapan".text = str(kelembapan_saat_ini) + "%"
	
	if data.has("pipes"):
		var ukuran_skala = Vector2(1.9, 1.9)
		var offset_dinamis = grid_offset
		var lebar_pixel_kotak = grid_pixel_size
		
		if data["ukuran_grid"] == "3x3":
			ukuran_skala = Vector2(1.4, 1.4)
			lebar_pixel_kotak = 95
			offset_dinamis = Vector2(185, 420)
		elif data["ukuran_grid"] == "4x4":
			ukuran_skala = Vector2(1.0, 1.0)
			lebar_pixel_kotak = 70
			offset_dinamis = Vector2(180, 400)
		
		for pipe_info in data["pipes"]:
			var objek_baru = null
			match pipe_info["jenis"]:
				"LURUS": objek_baru = PIPA_LURUS.instantiate()
				"SIKU": objek_baru = PIPA_SIKU.instantiate()
				"T": objek_baru = PIPA_T.instantiate()
				"X": objek_baru = PIPA_X.instantiate()
				"VALVE": objek_baru = VALVE.instantiate()
				"SOIL": objek_baru = SOIL.instantiate()
				"TANAMAN":
					objek_baru = TANAMAN.instantiate()
					daftar_tanaman.append(objek_baru)
					
			if objek_baru:
				objek_baru.position = Vector2((pipe_info["x"] * lebar_pixel_kotak) + offset_dinamis.x, (pipe_info["y"] * lebar_pixel_kotak) + offset_dinamis.y)
				objek_baru.scale = ukuran_skala
				
				if pipe_info["jenis"] == "TANAMAN":
					if objek_baru.has_method("set_jenis_tanaman"):
						objek_baru.set_jenis_tanaman(data["nama_tanaman"])
				
				if "rotation_degrees" in objek_baru:
					var rotasi_target = int(pipe_info["rotasi"]) % 360
					if rotasi_target < 0: rotasi_target += 360
					
					if pipe_info["jenis"] in ["LURUS", "SIKU", "T", "X"]:
						var pilihan_rotasi = [0, 90, 180, 270]
						pilihan_rotasi.erase(rotasi_target)
						objek_baru.rotation_degrees = pilihan_rotasi.pick_random()
						objek_baru.set_meta("rotasi_benar", rotasi_target)
						objek_baru.set_meta("jenis_pipa", pipe_info["jenis"])
					elif pipe_info["jenis"] == "VALVE":
						objek_baru.rotation_degrees = rotasi_target
						objek_baru.set_meta("rotasi_benar", rotasi_target)
						objek_baru.set_meta("jenis_pipa", "VALVE")
				
				if pipe_info["jenis"] == "VALVE" and objek_baru.has_node("Area2D"):
					objek_baru.get_node("Area2D").input_pickable = false
					
				$PipeGrid.add_child(objek_baru)

	if has_node("InterfaceUI/PanelFunFact"):
		if nomor_level == 1 and not tutorial_sudah_selesai:
			$InterfaceUI/PanelFunFact.visible = false
		else:
			$InterfaceUI/PanelFunFact.visible = true
			
		var label_ff = get_node_or_null("InterfaceUI/PanelFunFact/LblTeksFunFact")
		if label_ff: label_ff.text = data["fun_fact"]
			
		var bg_ff = get_node_or_null("InterfaceUI/PanelFunFact/BgFunFact")
		if bg_ff:
			if nomor_level == 1: bg_ff.texture = bg_funfact_1
			elif nomor_level == 2: bg_ff.texture = bg_funfact_2
			elif nomor_level == 3: bg_ff.texture = bg_funfact_3

	if nomor_level == 1 and not tutorial_sudah_selesai:
		call_deferred("mulai_tutorial_lala")
	else:
		var node_lala = get_node_or_null("InterfaceUI/PapanTutorialLala")
		if node_lala:
			node_lala.visible = false

func cek_semua_pipa_tersambung() -> bool:
	var semua_pipa_ok = true
	for child in $PipeGrid.get_children():
		if child.has_meta("rotasi_benar"):
			var target = int(round(child.get_meta("rotasi_benar"))) % 360
			if target < 0: target += 360
			var current = int(round(child.rotation_degrees)) % 360
			if current < 0: current += 360
			
			var jenis = child.get_meta("jenis_pipa")
			if jenis == "X": continue
			elif jenis == "LURUS":
				var target_is_horizontal = (target == 0 or target == 180)
				var current_is_horizontal = (current == 0 or current == 180)
				if target_is_horizontal != current_is_horizontal: semua_pipa_ok = false
			else:
				var selisih = abs(current - target)
				if selisih > 180: selisih = 360 - selisih
				if selisih > 25: semua_pipa_ok = false
					
	return semua_pipa_ok

func _on_btn_musik_pressed() -> void:
	mainkan_suara_klik() # Suara klik
	musik_aktif = not musik_aktif
	var bg_music = get_node_or_null("BgMusic")
	
	if musik_aktif:
		$InterfaceUI/BtnMusik.texture_normal = gambar_musik_hidup
		if bg_music:
			bg_music.stream_paused = false
	else:
		$InterfaceUI/BtnMusik.texture_normal = gambar_musik_mati
		if bg_music:
			bg_music.stream_paused = true 

func pemicu_menang_level() -> void:
	level_selesai = true
	
	# --- MAINKAN SUARA KEMENANGAN ---
	var sfx_win = get_node_or_null("SfxWin")
	if sfx_win:
		sfx_win.play()
	# --------------------------------
	
	if has_node("InterfaceUI/PanelFunFact"):
		$InterfaceUI/PanelFunFact.visible = false
	
	for tanaman in daftar_tanaman:
		if tanaman.has_method("ubah_ke_matang"):
			tanaman.ubah_ke_matang()
			
	koin_sekarang += 50
	if koin_sekarang > target_koin: koin_sekarang = target_koin
	perbarui_tampilan_koin()
	await get_tree().create_timer(1.5).timeout
	
	var node_papan_menang = null
	if has_node("PapanSelamat"): node_papan_menang = $PapanSelamat
	elif has_node("InterfaceUI/PapanSelamat"): node_papan_menang = $InterfaceUI/PapanSelamat
		
	if node_papan_menang:
		tampilkan_papan_menang_dengan_animasi(node_papan_menang)

func perbarui_tampilan_koin() -> void:
	if has_node("InterfaceUI/PnlKoin/TxtKoin"):
		$InterfaceUI/PnlKoin/TxtKoin.text = str(koin_sekarang)
		
	var node_papan_koin = get_node_or_null("InterfaceUI/PapanBeliHint/point/lblkoin")
	if node_papan_koin:
		var label_poin = node_papan_koin.get_node_or_null("Label")
		if not label_poin: label_poin = node_papan_koin.get_node_or_null("TxtPoint")
		if not label_poin:
			if node_papan_koin is Label: label_poin = node_papan_koin

		if label_poin: label_poin.text = str(koin_sekarang)
		else:
			var new_lbl = Label.new()
			new_lbl.name = "TxtPoint"
			new_lbl.text = str(koin_sekarang)
			new_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			new_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			new_lbl.size = node_papan_koin.size
			node_papan_koin.add_child(new_lbl)

	var file_koin = FileAccess.open(FILE_KOIN, FileAccess.WRITE)
	if file_koin:
		file_koin.store_string(str(koin_sekarang))
		file_koin.close()

func tampilkan_overlay_redup_di_belakang(target_node) -> void:
	var overlay = get_node_or_null("InterfaceUI/OverlayRedup")
	if not overlay: return
	
	overlay.global_position = Vector2.ZERO
	overlay.size = get_viewport_rect().size
	overlay.visible = true
	
	var parent = target_node.get_parent()
	if parent and overlay.get_parent() == parent:
		var target_idx = target_node.get_index()
		if overlay.get_index() > target_idx: parent.move_child(overlay, target_idx)
		else: parent.move_child(overlay, max(0, target_idx - 1))
	
	if target_node is CanvasItem: target_node.z_index = 10
	if overlay is CanvasItem: overlay.z_index = 5
		
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.65, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func sembunyikan_overlay_redup() -> void:
	var overlay = get_node_or_null("InterfaceUI/OverlayRedup")
	if overlay:
		var tween = create_tween()
		tween.tween_property(overlay, "color:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween.finished
		overlay.visible = false

func tampilkan_papan_menang_dengan_animasi(papan_node) -> void:
	tampilkan_overlay_redup_di_belakang(papan_node)
	papan_node.visible = true
	var ukuran_papan = Vector2(300, 300)
	if "size" in papan_node: ukuran_papan = papan_node.size
	elif "texture" in papan_node and papan_node.texture: ukuran_papan = papan_node.texture.get_size()
		
	if "pivot_offset" in papan_node: papan_node.pivot_offset = ukuran_papan / 2.0
		
	papan_node.scale = Vector2.ZERO
	papan_node.modulate.a = 0.0

	var tween = create_tween().set_parallel(true)
	tween.tween_property(papan_node, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(papan_node, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_slider_kelembapan_value_changed(value: float) -> void:
	if level_selesai: return
	var data = DATA_LEVEL[level_sekarang]
	kelembapan_saat_ini = int(100.0 - value)
	
	var slider_kelem = get_node_or_null("InterfaceUI/Kelembapan/SliderKelembapan")
	if slider_kelem:
		var label_angka = slider_kelem.get_node_or_null("LblAngkaKelembapan")
		if label_angka: label_angka.text = str(kelembapan_saat_ini) + "%"
			
	var rasio = float(kelembapan_saat_ini) / 100.0
	rasio = clampf(rasio, 0.0, 1.0)
	suhu_saat_ini = int(lerp(60.0, 10.0, rasio))
		
	var slider_suhu = get_node_or_null("InterfaceUI/Termometer/SliderSuhu")
	if slider_suhu:
		slider_suhu.set_value(suhu_saat_ini)
		var label_suhu = get_node_or_null("InterfaceUI/Termometer/LblAngkaSuhu")
		if label_suhu:
			label_suhu.text = str(suhu_saat_ini) + "°C"
			var tinggi_slider = slider_suhu.size.y
			var rasio_suhu_aktif = float(suhu_saat_ini - 10) / float(60 - 10)
			var area_aktif = tinggi_slider - 20
			var posisi_y_lokal = slider_suhu.position.y + 10 + (area_aktif * (1.0 - rasio_suhu_aktif))
			label_suhu.position = Vector2(slider_suhu.position.x + 27, posisi_y_lokal - 9)
			
	var label_sekarang = get_node_or_null("InterfaceUI/Termometer/LblSuhuSekarang")
	if label_sekarang: label_sekarang.text = str(suhu_saat_ini) + "°C"
			
	simulasi_suhu_sudah_pas = (suhu_saat_ini == data["target_suhu"])
	simulasi_kelembapan_sudah_pas = (kelembapan_saat_ini >= data["min_kelembapan"] and kelembapan_saat_ini <= data["max_kelembapan"])
	simulasi_pipa_tersambung = cek_semua_pipa_tersambung()
	if simulasi_pipa_tersambung and simulasi_suhu_sudah_pas and simulasi_kelembapan_sudah_pas:
		pemicu_menang_level()

func set_debit_air_simulasi(jenis_debit: String) -> void:
	var data = DATA_LEVEL[level_sekarang]
	var target_kelem_simulasi = 0
	
	match jenis_debit:
		"MATI": target_kelem_simulasi = 100 - data["kelembapan_awal"]
		"KECIL": target_kelem_simulasi = 100 - 30
		"SEDANG": target_kelem_simulasi = 100 - data["target_kelembapan"]
		"BESAR": target_kelem_simulasi = 100 - 90
			
	var slider_kelem = get_node_or_null("InterfaceUI/Kelembapan/SliderKelembapan")
	if slider_kelem: slider_kelem.value = target_kelem_simulasi
	simulasi_kelembapan_sudah_pas = (abs(kelembapan_saat_ini - data["target_kelembapan"]) <= 2)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1: set_debit_air_simulasi("KECIL")
		elif event.keycode == KEY_2: set_debit_air_simulasi("SEDANG")
		elif event.keycode == KEY_3: set_debit_air_simulasi("BESAR")

func lanjut_ke_level_berikutnya() -> void:
	level_sekarang += 1
	if level_sekarang > 3: level_sekarang = 1
		
	simulasi_pipa_tersambung = false
	simulasi_suhu_sudah_pas = false
	simulasi_kelembapan_sudah_pas = false
	
	if mode_debug == false: seed_level_ini = randi()
	else: seed_level_ini += 1
		
	muat_level(level_sekarang)

func _on_btn_next_pressed() -> void:
	mainkan_suara_klik() # Suara klik
	lanjut_ke_level_berikutnya()

func _on_btn_reset_pressed() -> void:
	if level_selesai: return
	
	# Suara klik tetap bunyi walau animasi gak ketemu
	mainkan_suara_klik() 
		
	var btn_reset = get_node_or_null("InterfaceUI/BtnReset")
	if not btn_reset: btn_reset = get_node_or_null("BtnReset") 
	if btn_reset: anim_tombol_klik(btn_reset)

	var overlay = get_node_or_null("InterfaceUI/OverlayRedup")
	if overlay:
		overlay.global_position = Vector2.ZERO
		overlay.size = get_viewport_rect().size
		overlay.visible = true
		overlay.z_index = 100 
		var tween_fade_in = create_tween()
		tween_fade_in.tween_property(overlay, "color:a", 0.75, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tween_fade_in.finished

	simulasi_pipa_tersambung = false
	simulasi_suhu_sudah_pas = false
	simulasi_kelembapan_sudah_pas = false
	muat_level(level_sekarang)

	if overlay:
		var tween_fade_out = create_tween()
		tween_fade_out.tween_property(overlay, "color:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween_fade_out.finished
		overlay.visible = false
		overlay.z_index = 0 

func _on_btn_ok_pressed() -> void:
	mainkan_suara_klik() # Suara klik
	if has_node("PapanSelamat"): $PapanSelamat.visible = false
	elif has_node("InterfaceUI/PapanSelamat"): $InterfaceUI/PapanSelamat.visible = false
	sembunyikan_overlay_redup()
	lanjut_ke_level_berikutnya()

func perbarui_tampilan_hint() -> void:
	if has_node("InterfaceUI/Hint/LblSisaHint"):
		$InterfaceUI/Hint/LblSisaHint.text = str(sisa_hint)

func _on_hint_pressed() -> void:
	mainkan_suara_klik() # Suara klik
	if level_selesai: return
	if sisa_hint <= 0:
		tampilkan_papan_hint_habis()
		return

	var daftar_pipa_salah: Array = []
	for child in $PipeGrid.get_children():
		if child.has_meta("rotasi_benar"):
			var target = int(round(child.get_meta("rotasi_benar"))) % 360
			if target < 0: target += 360
			var current = int(round(child.rotation_degrees)) % 360
			if current < 0: current += 360
			
			var jenis = child.get_meta("jenis_pipa")
			var salah: bool = false
			if jenis == "LURUS":
				if (target == 0 or target == 180) != (current == 0 or current == 180): salah = true
			elif jenis in ["SIKU", "T"]:
				var selisih = abs(current - target)
				if selisih > 180: selisih = 360 - selisih
				if selisih > 25: salah = true
				
			if salah: daftar_pipa_salah.append(child)

	if tahap_hint == 0:
		if daftar_pipa_salah.size() > 0:
			var pipa_target = daftar_pipa_salah.pick_random()
			if pipa_target.has_method("mulai_nyut_nyut"): pipa_target.mulai_nyut_nyut()
			tahap_hint = 1
		else:
			perbarui_papan_hint()
			tahap_hint = 2
		sisa_hint -= 1
		perbarui_tampilan_hint()

	elif tahap_hint == 1:
		var ada_pipa_diputar: bool = false
		for child in $PipeGrid.get_children():
			if "sedang_nyut" in child and child.sedang_nyut:
				if child.has_method("putar_otomatis_via_hint"):
					child.putar_otomatis_via_hint()
					ada_pipa_diputar = true
		
		if not ada_pipa_diputar and daftar_pipa_salah.size() > 0:
			var pipa_target = daftar_pipa_salah.pick_random()
			if pipa_target.has_method("putar_otomatis_via_hint"): pipa_target.putar_otomatis_via_hint()
				
		tahap_hint = 2
		sisa_hint -= 1
		perbarui_tampilan_hint()

	elif tahap_hint == 2:
		perbarui_papan_hint()
		sisa_hint -= 1
		perbarui_tampilan_hint()

func _on_buttonOk_Hint_pressed() -> void:
	if has_node("InterfaceUI/papan_hint"): $InterfaceUI/papan_hint.visible = false
	sembunyikan_overlay_redup()

func perbarui_papan_hint() -> void:
	var node_papan = get_node_or_null("InterfaceUI/papan_hint")
	if not node_papan: return
		
	var data = DATA_LEVEL[level_sekarang]
	var label_nama = node_papan.get_node_or_null("lbl_nama_tanaman")
	if label_nama: label_nama.text = data["nama_tanaman"]
		
	var texture_tanaman = node_papan.get_node_or_null("hint_tanaman")
	if texture_tanaman and data.has("path_gambar"):
		if ResourceLoader.exists(data["path_gambar"]): texture_tanaman.texture = load(data["path_gambar"])
			
	var label_kelembapan = node_papan.get_node_or_null("lbl_kelembapan")
	if label_kelembapan:
		var min_k = data.get("min_kelembapan", 50)
		var max_k = data.get("max_kelembapan", 70)
		label_kelembapan.text = "Kelembapan \t\t" + str(min_k) + "% - " + str(max_k) + "%"

	tampilkan_papan_menang_dengan_animasi(node_papan)

func tampilkan_papan_hint_habis() -> void:
	var node_papan = get_node_or_null("InterfaceUI/PapanHintHabis")
	if node_papan: tampilkan_papan_menang_dengan_animasi(node_papan)

func _on_btn_beli_hint_pressed() -> void:
	if has_node("InterfaceUI/PapanHintHabis"): $InterfaceUI/PapanHintHabis.visible = false
	var node_toko = get_node_or_null("InterfaceUI/PapanBeliHint")
	if node_toko:
		_reset_semua_seleksi_paket()
		perbarui_tampilan_koin()
		tampilkan_papan_menang_dengan_animasi(node_toko)

func _on_btn_close_hint_habis_pressed() -> void:
	if has_node("InterfaceUI/PapanHintHabis"): $InterfaceUI/PapanHintHabis.visible = false
	sembunyikan_overlay_redup()

func _on_btn_close_beli_hint_pressed() -> void:
	if has_node("InterfaceUI/PapanBeliHint"): $InterfaceUI/PapanBeliHint.visible = false
	sembunyikan_overlay_redup()

func beli_paket_hint(jumlah_hint: int, harga_koin: int) -> void:
	if koin_sekarang >= harga_koin:
		koin_sekarang -= harga_koin
		sisa_hint += jumlah_hint
		if sisa_hint > 0 and tahap_hint >= 3: tahap_hint = 0
		perbarui_tampilan_hint()
		perbarui_tampilan_koin()
		_on_btn_close_beli_hint_pressed()
	else:
		tampilkan_poin_tidak_cukup()

func mulai_tutorial_lala() -> void:
	indeks_dialog_lala = 0
	tampilkan_dialog_lala()

func tampilkan_dialog_lala() -> void:
	var node_lala = get_node_or_null("InterfaceUI/PapanTutorialLala")
	if not node_lala: return
	
	node_lala.visible = true
	var data_saat_ini = daftar_dialog_lala[indeks_dialog_lala]
	
	var lbl = node_lala.get_node_or_null("LblTeksLala")
	if not lbl: lbl = node_lala.get_node_or_null("KarakterLala/LblTeksLala")
	if lbl: lbl.text = data_saat_ini["teks"]
		
	atur_lubang_tutorial(node_lala, data_saat_ini)

# FUNGSI AJAIB PENGATUR LUBANG CLEAN & MULTI-HOLE
func atur_lubang_tutorial(node_lala: Control, data_dialog: Dictionary) -> void:
	var layar = get_viewport_rect().size
	
	var area_fokus = node_lala.get_node_or_null("AreaFokus")
	if area_fokus:
		area_fokus.visible = false
		area_fokus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	node_lala.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for child in node_lala.get_children():
		if child is ColorRect and child.name.begins_with("KotakGelapDinamis"):
			node_lala.remove_child(child)
			child.queue_free()
			
	var warna_gelap = Color(0, 0, 0, 0.65)
	if node_lala.has_node("GelapAtas"):
		warna_gelap = node_lala.get_node("GelapAtas").color
		
	for nama in ["GelapAtas", "GelapBawah", "GelapKiri", "GelapKanan"]:
		if node_lala.has_node(nama):
			node_lala.get_node(nama).visible = false
			node_lala.get_node(nama).mouse_filter = Control.MOUSE_FILTER_IGNORE

	var list_lubang = []
	if data_dialog.has("fokus_array"):
		for f in data_dialog["fokus_array"]:
			if f != Vector4(0,0,0,0):
				list_lubang.append(Rect2(f.x, f.y, f.z, f.w))
	elif data_dialog.has("fokus"):
		var f = data_dialog["fokus"]
		if f != Vector4(0,0,0,0):
			list_lubang.append(Rect2(f.x, f.y, f.z, f.w))

	var rects = [Rect2(0, 0, layar.x, layar.y)] 
	
	for lubang in list_lubang:
		var new_rects = []
		for r in rects:
			if not r.intersects(lubang):
				new_rects.append(r)
			else:
				if lubang.position.y > r.position.y: 
					new_rects.append(Rect2(r.position.x, r.position.y, r.size.x, lubang.position.y - r.position.y))
				if lubang.end.y < r.end.y: 
					new_rects.append(Rect2(r.position.x, lubang.end.y, r.size.x, r.end.y - lubang.end.y))
				if lubang.position.x > r.position.x: 
					new_rects.append(Rect2(r.position.x, max(r.position.y, lubang.position.y), lubang.position.x - r.position.x, min(r.end.y, lubang.end.y) - max(r.position.y, lubang.position.y)))
				if lubang.end.x < r.end.x: 
					new_rects.append(Rect2(lubang.end.x, max(r.position.y, lubang.position.y), r.end.x - lubang.end.x, min(r.end.y, lubang.end.y) - max(r.position.y, lubang.position.y)))
		rects = new_rects

	var z_index_pos = 0
	for r in rects:
		var kotak = ColorRect.new()
		kotak.name = "KotakGelapDinamis_" + str(z_index_pos)
		kotak.color = warna_gelap
		kotak.position = r.position
		kotak.size = r.size
		
		kotak.mouse_filter = Control.MOUSE_FILTER_STOP
		kotak.gui_input.connect(_on_papan_tutorial_lala_gui_input)
		
		node_lala.add_child(kotak)
		node_lala.move_child(kotak, z_index_pos) 
		z_index_pos += 1

func _on_papan_tutorial_lala_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		indeks_dialog_lala += 1
		if indeks_dialog_lala >= daftar_dialog_lala.size():
			tutup_tutorial_lala()
		else:
			tampilkan_dialog_lala()

func _on_btn_lewati_tutorial_pressed() -> void:
	mainkan_suara_klik() # Suara klik
	tutup_tutorial_lala()

func tutup_tutorial_lala() -> void:
	var node_lala = get_node_or_null("InterfaceUI/PapanTutorialLala")
	if node_lala: node_lala.visible = false
	
	tutorial_sudah_selesai = true
	var file = FileAccess.open(FILE_TUTORIAL, FileAccess.WRITE)
	if file:
		file.store_string("selesai")
		file.close()
	
	if has_node("InterfaceUI/PanelFunFact"):
		var panel_ff = $InterfaceUI/PanelFunFact
		panel_ff.visible = true
		panel_ff.scale = Vector2.ZERO
		panel_ff.pivot_offset = panel_ff.size / 2.0
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(panel_ff, "scale", Vector2.ONE, 0.4)

# ==========================================
# FUNGSI SUARA SLIDER KELEMBAPAN
# ==========================================
func _on_slider_drag_started() -> void:
	var sfx = get_node_or_null("SfxSlider")
	if sfx:
		sfx.play()

func _on_slider_drag_ended(_value_changed: bool) -> void:
	var sfx = get_node_or_null("SfxSlider")
	if sfx:
		sfx.stop()
