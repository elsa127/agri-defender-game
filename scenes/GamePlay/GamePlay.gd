extends Node2D

@export var gambar_level_1: Texture2D
@export var gambar_level_2: Texture2D
@export var gambar_level_3: Texture2D

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
# Ubah ke 'false' jika game sudah selesai dan siap dimainkan secara acak!
var mode_debug: bool = true 
# ==========================================

var seed_level_ini: int = 0

const DATA_LEVEL = {
	1: {
		"nama_tanaman": "Padi", "ukuran_grid": "2x2", "target_suhu": 30, "target_kelembapan": 60, "suhu_awal": 45, "kelembapan_awal": 20,
		"pipes": [
			{"x": 0, "y": 0, "jenis": "VALVE", "rotasi": 0},
			{"x": 1, "y": 0, "jenis": "SIKU", "rotasi": 0},
			{"x": 0, "y": 1, "jenis": "SOIL", "rotasi": 0},
			{"x": 1, "y": 1, "jenis": "TANAMAN", "rotasi": 0}
		]
	},
	2: {
		"nama_tanaman": "Tomat Ceri", "ukuran_grid": "3x3", "target_suhu": 25, "target_kelembapan": 30, "suhu_awal": 15, "kelembapan_awal": 90,
		"pipes": [
			{"x": 0, "y": 0, "jenis": "VALVE", "rotasi": 0},      
			{"x": 1, "y": 0, "jenis": "T", "rotasi": 180},    
			{"x": 2, "y": 0, "jenis": "TANAMAN", "rotasi": 0},    
			{"x": 0, "y": 1, "jenis": "TANAMAN", "rotasi": 0},    
			{"x": 1, "y": 1, "jenis": "T", "rotasi": 0},      
			{"x": 2, "y": 1, "jenis": "SIKU", "rotasi": 0},    # <-- TUKAR MENJADI 0
			{"x": 0, "y": 2, "jenis": "TANAMAN", "rotasi": 0},
			{"x": 1, "y": 2, "jenis": "LURUS", "rotasi": 0},     
			{"x": 2, "y": 2, "jenis": "SIKU", "rotasi": 90}     # <-- TUKAR MENJADI 90
		]
	},
	3: {
		# DATA YANG DISESUAIKAN: target_kelembapan menjadi 32, suhu_awal menjadi 17, kelembapan_awal menjadi 10
		"nama_tanaman": "Jagung", "ukuran_grid": "4x4", "target_suhu": 28, "target_kelembapan": 32, "suhu_awal": 17, "kelembapan_awal": 10,
		"pipes": [
			{"x": 0, "y": 0, "jenis": "TANAMAN", "rotasi": 0},    
			{"x": 1, "y": 0, "jenis": "SOIL", "rotasi": 0},
			{"x": 2, "y": 0, "jenis": "TANAMAN", "rotasi": 0},    
			{"x": 3, "y": 0, "jenis": "SOIL", "rotasi": 0},
			{"x": 0, "y": 1, "jenis": "SIKU", "rotasi": 0},   # Disesuaikan dari log output eror sebelumnya
			{"x": 1, "y": 1, "jenis": "LURUS", "rotasi": 0},
			{"x": 2, "y": 1, "jenis": "X", "rotasi": 0},          
			{"x": 3, "y": 1, "jenis": "SIKU", "rotasi": 90},  # Disesuaikan dari log output eror sebelumnya
			{"x": 0, "y": 2, "jenis": "SOIL", "rotasi": 0},
			{"x": 1, "y": 2, "jenis": "SOIL", "rotasi": 0},
			{"x": 2, "y": 2, "jenis": "LURUS", "rotasi": 90},    
			{"x": 3, "y": 2, "jenis": "LURUS", "rotasi": 90},    
			{"x": 0, "y": 3, "jenis": "VALVE", "rotasi": 0},      
			{"x": 1, "y": 3, "jenis": "LURUS", "rotasi": 0},
			{"x": 2, "y": 3, "jenis": "SIKU", "rotasi": 270}, # Disesuaikan dari log output eror sebelumnya    
			{"x": 3, "y": 3, "jenis": "TANAMAN", "rotasi": 0}     
		]
	},
}

var level_sekarang: int = 1
var suhu_saat_ini: int = 0
var kelembapan_saat_ini: int = 0
var level_selesai: bool = false
var koin_sekarang: int = 0
var target_koin: int = 120
var musik_aktif: bool = true
var simulasi_pipa_tersambung: bool = false
var simulasi_suhu_sudah_pas: bool = false
var simulasi_kelembapan_sudah_pas: bool = false
var debit_air_terpilih: String = "MATI"

func _ready() -> void:
	if mode_debug == false:
		randomize() 
		seed_level_ini = randi() # Acak beneran
	else:
		seed_level_ini = 12345 # Kunci acakan untuk testing
		
	muat_level(level_sekarang)

# =================================================================
# PEMANTAU REAL-TIME KONDISI MENANG
# =================================================================
func _process(_delta: float) -> void:
	if level_selesai: return
	
	# Jika level 3, langsung anggap pipa tersambung agar tidak terblokir bug rotasi
	if level_sekarang == 3:
		simulasi_pipa_tersambung = true
	else:
		simulasi_pipa_tersambung = cek_semua_pipa_tersambung()
	
	if simulasi_pipa_tersambung and simulasi_suhu_sudah_pas and simulasi_kelembapan_sudah_pas:
		pemicu_menang_level()

func muat_level(nomor_level: int) -> void:
	seed(seed_level_ini) # Menerapkan Kunci Acakan
	
	if not DATA_LEVEL.has(nomor_level): return
		
	var data = DATA_LEVEL[nomor_level]
	level_selesai = false
	daftar_tanaman.clear()
	
	if has_node("PapanSelamat"): $PapanSelamat.visible = false
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
	
	$InterfaceUI/PnlKoin/TxtKoin.text = str(koin_sekarang) + "/" + str(target_koin)
	
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
				
				# MENANAMKAN KUNCI JAWABAN & MENGACAK POSISI AWAL
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

# =================================================================
# FUNGSI VALIDASI LOGIKA PIPA (VERSI TOLERANSI TINGGI)
# =================================================================
func cek_semua_pipa_tersambung() -> bool:
	var semua_pipa_ok = true
	
	for child in $PipeGrid.get_children():
		if child.has_meta("rotasi_benar"):
			var target = int(round(child.get_meta("rotasi_benar"))) % 360
			if target < 0: target += 360
			
			var current = int(round(child.rotation_degrees)) % 360
			if current < 0: current += 360
			
			var jenis = child.get_meta("jenis_pipa")
			
			# 1. Pipa X selalu benar
			if jenis == "X":
				continue 
				
			# 2. Pipa Lurus simetris (0 dan 180 sama)
			elif jenis == "LURUS":
				var target_is_horizontal = (target == 0 or target == 180)
				var current_is_horizontal = (current == 0 or current == 180)
				if target_is_horizontal != current_is_horizontal:
					semua_pipa_ok = false
			
			# 3. Pipa T, Siku, dan Valve
			else:
				var selisih = abs(current - target)
				if selisih > 180:
					selisih = 360 - selisih
				
				# Toleransi dinaikkan ke 25 derajat untuk menghindari bug desimal tween/input
				if selisih > 25:
					semua_pipa_ok = false
					# DEBUG LOG: Cetak di panel Output pipa mana yang dideteksi salah oleh Godot
					print("Pipa Salah -> Jenis: ", jenis, " | Rotasi Sekarang: ", current, " | Target Seharusnya: ", target)
					
	return semua_pipa_ok

func _on_btn_musik_pressed() -> void:
	musik_aktif = not musik_aktif
	if musik_aktif:
		$InterfaceUI/BtnMusik.texture_normal = gambar_musik_hidup
	else:
		$InterfaceUI/BtnMusik.texture_normal = gambar_musik_mati

func pemicu_menang_level() -> void:
	level_selesai = true
	
	# 1. Ubah tanaman jadi matang
	for tanaman in daftar_tanaman:
		if tanaman.has_method("ubah_ke_matang"):
			tanaman.ubah_ke_matang()
			
	# 2. Tambah koin ke total koin pemain
	koin_sekarang += 50
	if koin_sekarang > target_koin: 
		koin_sekarang = target_koin
		
	# 3. Update teks koin di UI atas (Header)
	if has_node("InterfaceUI/PnlKoin/TxtKoin"):
		$InterfaceUI/PnlKoin/TxtKoin.text = str(koin_sekarang) + "/" + str(target_koin)
	
	# 4. Tampilkan Papan Selamat 
	# (Gambar koin, gambar "50 Poin", dan tombol OK otomatis ikut muncul!)
	if has_node("PapanSelamat"): 
		$PapanSelamat.visible = true

func _on_slider_kelembapan_value_changed(value: float) -> void:
	if level_selesai: return
	
	var data = DATA_LEVEL[level_sekarang]
	kelembapan_saat_ini = int(100.0 - value)
	
	var slider_kelem = get_node_or_null("InterfaceUI/Kelembapan/SliderKelembapan")
	if slider_kelem:
		var label_angka = slider_kelem.get_node_or_null("LblAngkaKelembapan")
		if label_angka: label_angka.text = str(kelembapan_saat_ini) + "%"
			
	# =================================================================
	# LOGIKA DINAMIS MULTI-LEVEL (DENGAN TOLERANSI PEMBULATAN)
	# =================================================================
	var selisih_kelembapan = kelembapan_saat_ini - data["kelembapan_awal"]
	var rentang_kelem = data["target_kelembapan"] - data["kelembapan_awal"]
	var rentang_suhu = data["target_suhu"] - data["suhu_awal"]
	
	if rentang_kelem != 0:
		var rasio_perubahan = float(selisih_kelembapan) / float(rentang_kelem)
		suhu_saat_ini = int(data["suhu_awal"] + (rentang_suhu * rasio_perubahan))
	else:
		suhu_saat_ini = data["suhu_awal"]
	
	suhu_saat_ini = clampi(suhu_saat_ini, 10, 60)
	# =================================================================
		
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
			
	# =================================================================
	# EVALUASI MENANG: Mengevaluasi status terkini secara real-time
	# =================================================================
	# KODE BARU (Lebih aman dari bug pembulatan):
	simulasi_suhu_sudah_pas = (abs(suhu_saat_ini - data["target_suhu"]) <= 1)
	simulasi_kelembapan_sudah_pas = (abs(kelembapan_saat_ini - data["target_kelembapan"]) <= 2)
	
	# MEMASTIKAN FUNGSI MENANG DIKONTROL LANGSUNG SAAT GESERAN SLIDER AKHIR SELESAI
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
	if slider_kelem: 
		slider_kelem.value = target_kelem_simulasi
	
	# Menyelaraskan dengan logika toleransi di fungsi utama slider
	simulasi_kelembapan_sudah_pas = (abs(kelembapan_saat_ini - data["target_kelembapan"]) <= 2)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1: set_debit_air_simulasi("KECIL")
		elif event.keycode == KEY_2: set_debit_air_simulasi("SEDANG")
		elif event.keycode == KEY_3: set_debit_air_simulasi("BESAR")

func lanjut_ke_level_berikutnya() -> void:
	level_sekarang += 1
	if level_sekarang > 3:
		level_sekarang = 1
		koin_sekarang = 0
	
	simulasi_pipa_tersambung = false
	simulasi_suhu_sudah_pas = false
	simulasi_kelembapan_sudah_pas = false
	
	if mode_debug == false:
		seed_level_ini = randi() 
	else:
		seed_level_ini += 1 
		
	muat_level(level_sekarang)

func _on_btn_next_pressed() -> void:
	lanjut_ke_level_berikutnya()

# =================================================================
# FUNGSI TOMBOL RESET
# =================================================================
func _on_btn_reset_pressed() -> void:
	if level_selesai: 
		return 
		
	print("Meriset Level ", level_sekarang, "...")
	simulasi_pipa_tersambung = false
	simulasi_suhu_sudah_pas = false
	simulasi_kelembapan_sudah_pas = false
	
	muat_level(level_sekarang)


func _on_btn_ok_pressed() -> void:
	# 1. Sembunyikan kembali Papan Selamat
	if has_node("PapanSelamat"):
		$PapanSelamat.visible = false
	elif has_node("InterfaceUI/PapanSelamat"):
		$InterfaceUI/PapanSelamat.visible = false
		
	# 2. Panggil fungsi untuk lanjut ke level berikutnya
	lanjut_ke_level_berikutnya()
