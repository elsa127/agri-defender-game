extends Node2D

# Slot Export Visual untuk Gambar Board Level di Inspector
@export var gambar_level_1: Texture2D
@export var gambar_level_2: Texture2D
@export var gambar_level_3: Texture2D

# Load aset gambar musik hidup/mati
@onready var gambar_musik_hidup = preload("res://asset_gambar/gambar_button/button_musik_hidup.png")
@onready var gambar_musik_mati = preload("res://asset_gambar/gambar_button/button_musik_mati.png")

# =================================================================
# 1. DEKLARASI ASET SCENE KEPINGAN GRID
# =================================================================
const PIPA_LURUS = preload("res://scenes/scene_pipa/pipa_lurus.tscn")
const PIPA_SIKU = preload("res://scenes/scene_pipa/pipa_siku.tscn")
const PIPA_T = preload("res://scenes/scene_pipa/pipa_t.tscn")
const PIPA_X = preload("res://scenes/scene_pipa/pipa_x.tscn")
const VALVE = preload("res://scenes/scene_pipa/solenoid_valve.tscn") # Hulu air (soil.png)
const SOIL = preload("res://scenes/tanaman/tanahkosong.tscn")       # Tanah kosong statis
const TANAMAN = preload("res://scenes/tanaman/tanaman.tscn")         # Induk tanaman pintar

# Referensi untuk mencatat objek tanaman yang sedang aktif di layar
var objek_tanaman_aktif: Node2D = null

# =================================================================
# CONFIGURATION GRID (Ramping & Geser Kiri untuk Ruang UI Kanan)
# =================================================================
var grid_pixel_size = 135 # Jarak antar kotak dikecilkan agar rapat dan hemat tempat
var grid_offset = Vector2(190, 440) # Digeser ke kiri (110) untuk space barometer di kanan

const DATA_LEVEL = {
	1: {
		"nama_tanaman": "Padi",
		"ukuran_grid": "2x2",
		"target_suhu": 30,
		"target_kelembapan": 60,
		"suhu_awal": 45,
		"kelembapan_awal": 20,
		"pipes": [
			# Susunan Map Level 1 (2x2)
			{"x": 0, "y": 0, "jenis": "VALVE", "rotasi": 0},    # Pintu Air Start (Kiri Atas)
			{"x": 1, "y": 0, "jenis": "SIKU", "rotasi": 90},    # Pipa Belok (Kanan Atas)
			{"x": 0, "y": 1, "jenis": "SOIL", "rotasi": 0},     # Tanah Kosong (Kiri Bawah)
			{"x": 1, "y": 1, "jenis": "TANAMAN", "rotasi": 0}   # Padi Mentah (Kanan Bawah)
		]
	},
	2: {
		"nama_tanaman": "Tomat Ceri",
		"ukuran_grid": "3x3",
		"target_suhu": 24,
		"target_kelembapan": 75,
		"suhu_awal": 15,
		"kelembapan_awal": 90,
		"pipes": [
			# Susunan Map Level 2 (3x3)
			{"x": 0, "y": 0, "jenis": "VALVE", "rotasi": 0},
			{"x": 1, "y": 0, "jenis": "LURUS", "rotasi": 90},
			{"x": 2, "y": 0, "jenis": "SIKU", "rotasi": 90},
			{"x": 0, "y": 1, "jenis": "LURUS", "rotasi": 0},
			{"x": 1, "y": 1, "jenis": "SOIL", "rotasi": 0},
			{"x": 2, "y": 1, "jenis": "LURUS", "rotasi": 0},
			{"x": 0, "y": 2, "jenis": "SIKU", "rotasi": 270},
			{"x": 1, "y": 2, "jenis": "LURUS", "rotasi": 90},
			{"x": 2, "y": 2, "jenis": "TANAMAN", "rotasi": 0}
		]
	},
	3: {
		"nama_tanaman": "Jagung",
		"ukuran_grid": "3x3",
		"target_suhu": 28,
		"target_kelembapan": 55,
		"suhu_awal": 50,
		"kelembapan_awal": 10,
		"pipes": [
			# Susunan Map Level 3 (3x3)
			{"x": 0, "y": 0, "jenis": "VALVE", "rotasi": 90},
			{"x": 1, "y": 0, "jenis": "SIKU", "rotasi": 0},
			{"x": 2, "y": 0, "jenis": "SOIL", "rotasi": 0},
			{"x": 0, "y": 1, "jenis": "SIKU", "rotasi": 90},
			{"x": 1, "y": 1, "jenis": "LURUS", "rotasi": 0},
			{"x": 2, "y": 1, "jenis": "SIKU", "rotasi": 180},
			{"x": 0, "y": 2, "jenis": "SOIL", "rotasi": 0},
			{"x": 1, "y": 2, "jenis": "SIKU", "rotasi": 270},
			{"x": 2, "y": 2, "jenis": "TANAMAN", "rotasi": 0}
		]
	}
}

# Manajemen Level & Status Game
var level_sekarang: int = 1
var suhu_saat_ini: int = 0
var kelembapan_saat_ini: int = 0
var level_selesai: bool = false

# Sistem Koin
var koin_sekarang: int = 0
var target_koin: int = 120

# Saklar Musik
var musik_aktif: bool = true

# =================================================================
# SAKLAR LOGIKA SIMULASI (UNTUK TESTING TUGAS LANGKAH 5)
# =================================================================
var simulasi_pipa_tersambung: bool = false
var simulasi_suhu_sudah_pas: bool = false
var simulasi_kelembapan_sudah_pas: bool = false

# =================================================================
# TAMBAHAN: VARIABEL LOGIKA SIMULASI DEBIT AIR & KELEMBAPAN 
# =================================================================
var suhu_sekarang: int = 0
var debit_air_terpilih: String = "MATI"


func _ready() -> void:
	muat_level(level_sekarang)


func muat_level(nomor_level: int) -> void:
	if not DATA_LEVEL.has(nomor_level):
		return
		
	var data = DATA_LEVEL[nomor_level]
	level_selesai = false
	objek_tanaman_aktif = null
	
	# Sembunyikan papan selamat jika ada
	if has_node("PapanSelamat"):
		$PapanSelamat.visible = false
		
	# 1. BERSIHKAN PENGHUNI GRID SEBELUMNYA
	for child in $PipeGrid.get_children():
		child.queue_free()
	
	# 2. GANTI GAMBAR BOARD UTAMA DI ATAS
	if nomor_level == 1 and gambar_level_1:
		$BoardLv1.texture = gambar_level_1
	elif nomor_level == 2 and gambar_level_2:
		$BoardLv1.texture = gambar_level_2
	elif nomor_level == 3 and gambar_level_3:
		$BoardLv1.texture = gambar_level_3
	
	suhu_saat_ini = data["suhu_awal"]
	kelembapan_saat_ini = data["kelembapan_awal"]
	
	# TAMBAHAN INITIALIZATION SAAT LEVEL DIMUAT
	suhu_sekarang = data["suhu_awal"]
	debit_air_terpilih = "MATI"
	simulasi_suhu_sudah_pas = (suhu_sekarang == data["target_suhu"])
	simulasi_kelembapan_sudah_pas = (kelembapan_saat_ini == data["target_kelembapan"])
	
	if has_node("SliderSuhu"):
		$SliderSuhu.value = suhu_sekarang
		if has_node("SliderSuhu/LblAngkaSuhu"):
			$SliderSuhu/LblAngkaSuhu.text = str(suhu_sekarang) + "°C"
			
	if has_node("Kelembapan/SliderKelembapan"):
		$Kelembapan/SliderKelembapan.value = kelembapan_saat_ini
		if has_node("Kelembapan/SliderKelembapan/LblAngkaKelembapan"):
			$Kelembapan/SliderKelembapan/LblAngkaKelembapan.text = str(kelembapan_saat_ini) + "%"
	
	# Update Tampilan Skor Koin UI
	$InterfaceUI/PnlKoin/TxtKoin.text = str(koin_sekarang) + "/" + str(target_koin)
	
	# 3. GENERATOR OBJEK GRID OTOMATIS
	if data.has("pipes"):
		for pipe_info in data["pipes"]:
			var objek_baru = null
			
			match pipe_info["jenis"]:
				"LURUS":
					objek_baru = PIPA_LURUS.instantiate()
				"SIKU":
					objek_baru = PIPA_SIKU.instantiate()
				"VALVE":
					objek_baru = VALVE.instantiate()
				"SOIL":
					objek_baru = SOIL.instantiate()
				"TANAMAN":
					objek_baru = TANAMAN.instantiate()
					objek_tanaman_aktif = objek_baru 
					
			if objek_baru:
				# Kalkulasi posisi koordinat grid ke koordinat pixel layar
				var posisi_pixel_x = (pipe_info["x"] * grid_pixel_size) + grid_offset.x
				var posisi_pixel_y = (pipe_info["y"] * grid_pixel_size) + grid_offset.y
				
				objek_baru.position = Vector2(posisi_pixel_x, posisi_pixel_y)
				
				# AUTO-SCALE: Dikecilkan secara proporsional agar hemat ruang
				objek_baru.scale = Vector2(1.9, 1.9)
				
				# Set jenis variasi visual tanaman (Padi/Tomat/Jagung)
				if pipe_info["jenis"] == "TANAMAN" and objek_baru.has_method("set_jenis_tanaman"):
					objek_baru.set_jenis_tanaman(data["nama_tanaman"])
				
				# Terapkan rotasi awal dari data level (Khusus tipe pipa & valve)
				if "rotation_degrees" in objek_baru and pipe_info["jenis"] in ["LURUS", "SIKU", "VALVE"]:
					objek_baru.rotation_degrees = pipe_info["rotasi"]
				
				# KUNCI MUTLAK: Jika jenis kepingan adalah VALVE, matikan area deteksi kliknya
				if pipe_info["jenis"] == "VALVE":
					if objek_baru.has_node("Area2D"):
						objek_baru.get_node("Area2D").input_pickable = false
					
				$PipeGrid.add_child(objek_baru)
	
	print("====================================")
	print("BERHASIL GENERATE GRID: LEVEL ", nomor_level)
	print("Ukuran Grid: ", data["ukuran_grid"])
	print("Tanaman Level Ini: ", data["nama_tanaman"])
	print("====================================")


# =================================================================
# LOGIKA TOMBOL MUSIK
# =================================================================
func _on_btn_musik_pressed() -> void:
	musik_aktif = not musik_aktif
	if musik_aktif:
		$InterfaceUI/BtnMusik.texture_normal = gambar_musik_hidup
		print("Musik Menyala")
	else:
		$InterfaceUI/BtnMusik.texture_normal = gambar_musik_mati
		print("Musik Dimatikan")


# =================================================================
# LOGIKA CEK KEMENANGAN & KOIN
# =================================================================
func cek_kondisi_menang() -> void:
	if level_selesai: 
		return
		
	if simulasi_pipa_tersambung and simulasi_suhu_sudah_pas and simulasi_kelembapan_sudah_pas:
		pemicu_menang_level()
	else:
		print("Belum menang. Periksa kembali pipa atau slider UI kamu!")


func pemicu_menang_level() -> void:
	level_selesai = true
	print("Selamat! Kamu Menang!")
	
	# Pemicu agar visual tanaman otomatis berubah menjadi matang
	if objek_tanaman_aktif and objek_tanaman_aktif.has_method("ubah_ke_matang"):
		objek_tanaman_aktif.ubah_ke_matang()
		
	if has_node("PapanSelamat"):
		$PapanSelamat.visible = true 
	
	koin_sekarang += 40
	if koin_sekarang > target_koin:
		koin_sekarang = target_koin
		
	$InterfaceUI/PnlKoin/TxtKoin.text = str(koin_sekarang) + "/" + str(target_koin)


# =================================================================
# TAMBAHAN: FUNGSI RESPON GESER SLIDER SUHU & UPDATE OTOMATIS KELEMBAPAN
# =================================================================
func _on_slider_suhu_value_changed(value: float) -> void:
	if level_selesai: return
	suhu_sekarang = int(value)
	suhu_saat_ini = int(value)
	
	if has_node("SliderSuhu/LblAngkaSuhu"):
		$SliderSuhu/LblAngkaSuhu.text = str(suhu_sekarang) + "°C"
	
	simulasi_suhu_sudah_pas = (suhu_sekarang == DATA_LEVEL[level_sekarang]["target_suhu"])
	cek_kondisi_menang()

func set_debit_air_simulasi(jenis_debit: String) -> void:
	debit_air_terpilih = jenis_debit
	var data = DATA_LEVEL[level_sekarang]
	
	match debit_air_terpilih:
		"MATI":
			kelembapan_saat_ini = data["kelembapan_awal"]
		"KECIL":
			kelembapan_saat_ini = 40
		"SEDANG":
			kelembapan_saat_ini = data["target_kelembapan"] # Target level 1 (60)
		"BESAR":
			kelembapan_saat_ini = 95
			
	# MENYESUAIKAN PATH BARU: Karena sekarang sudah di dalam InterfaceUI
	var slider_kelem = get_node_or_null("InterfaceUI/Kelembapan/SliderKelembapan")
	
	if slider_kelem:
		# Set nilai slider secara paksa
		slider_kelem.value = kelembapan_saat_ini
		print("BERHASIL: Slider Kelembapan bergerak ke -> ", kelembapan_saat_ini)
		
		# Menembak LblAngkaKelembapan yang sudah kamu buat
		var label_angka = slider_kelem.get_node_or_null("LblAngkaKelembapan")
		if label_angka:
			label_angka.text = str(kelembapan_saat_ini) + "%"
	else:
		print("ERROR: Jalur Node salah, tidak ditemukan di InterfaceUI/Kelembapan/SliderKelembapan")
			
	simulasi_kelembapan_sudah_pas = (kelembapan_saat_ini == data["target_kelembapan"])
	cek_kondisi_menang()


# =================================================================
# FUNGSI TESTING SIMULATOR KEYBOARD
# =================================================================
func _input(event: InputEvent) -> void:
	# Tekan SPASI untuk mengecek kondisi kemenangan saat ini
	if event.is_action_pressed("ui_accept"): 
		print("--- MENCOBA TES CEK KEMENANGAN ---")
		cek_kondisi_menang()
		
	# Tekan tombol TAB (ui_focus_next) untuk simulasi paksa menang (Auto-Win)
	if event.is_action_pressed("ui_focus_next"):
		print("--- SIMULASI AUTO-WIN DIAKTIFKAN ---")
		simulasi_pipa_tersambung = true
		simulasi_suhu_sudah_pas = true
		simulasi_kelembapan_sudah_pas = true
		cek_kondisi_menang()
		
	# TAMBAHAN: TOMBOL TESTING DEBIT AIR (Gunakan Angka 1, 2, 3 di Keyboard untuk Demo)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			print("--- SIMULASI: DEBIT AIR KECIL (40%) ---")
			set_debit_air_simulasi("KECIL")
		elif event.keycode == KEY_2:
			print("--- SIMULASI: DEBIT AIR SEDANG (TARGET IDEAL) ---")
			simulasi_pipa_tersambung = true # Pura-pura pipa dialiri air sepenuhnya
			set_debit_air_simulasi("SEDANG")
		elif event.keycode == KEY_3:
			print("--- SIMULASI: DEBIT AIR BESAR (95%) ---")
			set_debit_air_simulasi("BESAR")
