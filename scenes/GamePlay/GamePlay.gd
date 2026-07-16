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
const SOIL = preload("res://scenes/tanaman/tanahkosong.tscn")        # Tanah kosong statis
const TANAMAN = preload("res://scenes/tanaman/tanaman.tscn")         # Induk tanaman pintar

# Referensi untuk mencatat objek tanaman yang sedang aktif di layar
var objek_tanaman_aktif: Node2D = null

# =================================================================
# CONFIGURATION GRID (Ramping & Pas di Tengah Layar)
# =================================================================
var grid_pixel_size = 135 
var grid_offset = Vector2(190, 440) 

const DATA_LEVEL = {
	1: {
		"nama_tanaman": "Padi",
		"ukuran_grid": "2x2",
		"target_suhu": 30,
		"target_kelembapan": 60,
		"suhu_awal": 45,
		"kelembapan_awal": 20,
		"pipes": [
			{"x": 0, "y": 0, "jenis": "VALVE", "rotasi": 0},
			{"x": 1, "y": 0, "jenis": "SIKU", "rotasi": 90},
			{"x": 0, "y": 1, "jenis": "SOIL", "rotasi": 0},
			{"x": 1, "y": 1, "jenis": "TANAMAN", "rotasi": 0}
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

# Saklar Logika Kemenangan
var simulasi_pipa_tersambung: bool = false
var simulasi_suhu_sudah_pas: bool = false
var simulasi_kelembapan_sudah_pas: bool = false

var debit_air_terpilih: String = "MATI"


func _ready() -> void:
	muat_level(level_sekarang)


func muat_level(nomor_level: int) -> void:
	if not DATA_LEVEL.has(nomor_level):
		return
		
	var data = DATA_LEVEL[nomor_level]
	level_selesai = false
	objek_tanaman_aktif = null
	
	if has_node("PapanSelamat"):
		$PapanSelamat.visible = false
		
	for child in $PipeGrid.get_children():
		child.queue_free()
	
	if nomor_level == 1 and gambar_level_1:
		$BoardLv1.texture = gambar_level_1
	elif nomor_level == 2 and gambar_level_2:
		$BoardLv1.texture = gambar_level_2
	elif nomor_level == 3 and gambar_level_3:
		$BoardLv1.texture = gambar_level_3
	
	suhu_saat_ini = data["suhu_awal"]
	kelembapan_saat_ini = data["kelembapan_awal"]
	debit_air_terpilih = "MATI"
	
	simulasi_suhu_sudah_pas = (suhu_saat_ini == data["target_suhu"])
	simulasi_kelembapan_sudah_pas = (kelembapan_saat_ini == data["target_kelembapan"])
	
	# =================================================================
	# --- BAGIAN PENTING: SINKRONISASI TAMPILAN AWAL SUHU & TARGET ---
	# =================================================================
	var node_slider_suhu = get_node_or_null("InterfaceUI/Termometer/SliderSuhu")
	var node_label_target = get_node_or_null("InterfaceUI/Termometer/LblTargetSuhu")
	var node_label_sekarang = get_node_or_null("InterfaceUI/Termometer/LblSuhuSekarang")
	
	# 1. Atur nilai awal Slider Suhu
	if node_slider_suhu:
		node_slider_suhu.value = suhu_saat_ini
		
		# 2. Update angka di samping bulat putih slider beserta posisi Y awalnya
		var label_angka = node_slider_suhu.get_node_or_null("LblAngkaSuhu")
		if not label_angka:
			label_angka = get_node_or_null("InterfaceUI/Termometer/LblAngkaSuhu")
			
		if label_angka:
			label_angka.text = str(suhu_saat_ini) + "°C"
			
			# Hitung posisi Y awal agar pas di tengah tombol grabber saat game mulai
			var suhu_min = 10
			var suhu_max = 60
			var tinggi_slider = node_slider_suhu.size.y
			var rasio_suhu = float(suhu_saat_ini - suhu_min) / float(suhu_max - suhu_min)
			var area_aktif = tinggi_slider - 20
			var posisi_y_lokal = node_slider_suhu.position.y + 10 + (area_aktif * (1.0 - rasio_suhu))
			
			label_angka.position = Vector2(node_slider_suhu.position.x + 22, posisi_y_lokal - 12)
			
	# 3. Tampilkan target level (tetap diam di bawah tulisan TARGET)
	if node_label_target:
		node_label_target.text = str(data["target_suhu"]) + "°C"
		
	# 4. Tampilkan suhu awal di kotak hijau besar atas (LblSuhuSekarang)
	if node_label_sekarang:
		node_label_sekarang.text = str(suhu_saat_ini) + "°C"
	# =================================================================
			
	if has_node("InterfaceUI/Kelembapan/SliderKelembapan"):
		$"InterfaceUI/Kelembapan/SliderKelembapan".value = kelembapan_saat_ini
		if has_node("InterfaceUI/Kelembapan/SliderKelembapan/LblAngkaKelembapan"):
			$"InterfaceUI/Kelembapan/SliderKelembapan/LblAngkaKelembapan".text = str(kelembapan_saat_ini) + "%"
	
	$InterfaceUI/PnlKoin/TxtKoin.text = str(koin_sekarang) + "/" + str(target_koin)
	
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
				var posisi_pixel_x = (pipe_info["x"] * grid_pixel_size) + grid_offset.x
				var posisi_pixel_y = (pipe_info["y"] * grid_pixel_size) + grid_offset.y
				
				objek_baru.position = Vector2(posisi_pixel_x, posisi_pixel_y)
				objek_baru.scale = Vector2(1.9, 1.9)
				
				if pipe_info["jenis"] == "TANAMAN" and objek_baru.has_method("set_jenis_tanaman"):
					objek_baru.set_jenis_tanaman(data["nama_tanaman"])
				
				if "rotation_degrees" in objek_baru and pipe_info["jenis"] in ["LURUS", "SIKU", "VALVE"]:
					objek_baru.rotation_degrees = pipe_info["rotasi"]
				
				if pipe_info["jenis"] == "VALVE":
					if objek_baru.has_node("Area2D"):
						objek_baru.get_node("Area2D").input_pickable = false
					
				$PipeGrid.add_child(objek_baru)


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
# LOGIKA CEK KEMENANGAN
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
	
	if objek_tanaman_aktif and objek_tanaman_aktif.has_method("ubah_ke_matang"):
		objek_tanaman_aktif.ubah_ke_matang()
		
	if has_node("PapanSelamat"):
		$PapanSelamat.visible = true 
	
	koin_sekarang += 40
	if koin_sekarang > target_koin:
		koin_sekarang = target_koin
		
	$InterfaceUI/PnlKoin/TxtKoin.text = str(koin_sekarang) + "/" + str(target_koin)


# =================================================================
# RESPON REAL-TIME SAAT PEMAIN MENGGESER SLIDER KELEMBAPAN
# =================================================================
func _on_slider_kelembapan_value_changed(value: float) -> void:
	if level_selesai: return
	
	var nilai_slider_asli = value
	var data = DATA_LEVEL[level_sekarang]
	
	# Visual Kiri = Hijau (Lembap/100%) dan Kanan = Merah (Kering/0%)
	kelembapan_saat_ini = int(100.0 - nilai_slider_asli)
	
	var slider_kelem = get_node_or_null("InterfaceUI/Kelembapan/SliderKelembapan")
	if slider_kelem:
		var label_angka = slider_kelem.get_node_or_null("LblAngkaKelembapan")
		if label_angka:
			label_angka.text = str(kelembapan_saat_ini) + "%"
			
	# Hitung Suhu sejajar arah geser slider (Kanan/Merah = Suhu Tinggi)
	var rentang_kelembapan = 100.0
	var rasio_posisi = float(nilai_slider_asli) / rentang_kelembapan
	
	var suhu_min = 10
	var suhu_max = 60
	
	suhu_saat_ini = int(suhu_min + ((suhu_max - suhu_min) * rasio_posisi))
		
	# Update Tampilan Barometer Suhu Sekarang secara Real-Time
	var slider_suhu = get_node_or_null("InterfaceUI/Termometer/SliderSuhu")
	if slider_suhu:
		slider_suhu.set_value(suhu_saat_ini)
		
		var label_suhu = get_node_or_null("InterfaceUI/Termometer/LblAngkaSuhu")
		if label_suhu:
			label_suhu.text = str(suhu_saat_ini) + "°C"
			
			var tinggi_slider = slider_suhu.size.y
			var rasio_suhu_aktif = float(suhu_saat_ini - suhu_min) / float(suhu_max - suhu_min)
			var area_aktif = tinggi_slider - 20 
			var posisi_y_lokal = slider_suhu.position.y + 10 + (area_aktif * (1.0 - rasio_suhu_aktif))
			
			label_suhu.position = Vector2(slider_suhu.position.x + 27, posisi_y_lokal - 9)
			
	# =================================================================
	# --- BAGIAN PENTING: UPDATE KOTAK HIJAU BESAR ATAS (SUHU SEKARANG) ---
	# =================================================================
	var label_sekarang = get_node_or_null("InterfaceUI/Termometer/LblSuhuSekarang")
	if label_sekarang:
		label_sekarang.text = str(suhu_saat_ini) + "°C"
	# =================================================================
			
	simulasi_kelembapan_sudah_pas = (kelembapan_saat_ini == data["target_kelembapan"])
	simulasi_suhu_sudah_pas = (suhu_saat_ini == data["target_suhu"])
	
	cek_kondisi_menang()


# =================================================================
# SIMULATOR KEYBOARD DEBIT AIR
# =================================================================
func set_debit_air_simulasi(jenis_debit: String) -> void:
	var data = DATA_LEVEL[level_sekarang]
	var target_kelem_simulasi = 0
	
	match jenis_debit:
		"MATI":
			target_kelem_simulasi = 100 - data["kelembapan_awal"]
		"KECIL":
			target_kelem_simulasi = 100 - 30
		"SEDANG":
			target_kelem_simulasi = 100 - data["target_kelembapan"]
		"BESAR":
			target_kelem_simulasi = 100 - 90
			
	var slider_kelem = get_node_or_null("InterfaceUI/Kelembapan/SliderKelembapan")
	if slider_kelem:
		slider_kelem.value = target_kelem_simulasi
		
	simulasi_kelembapan_sudah_pas = (kelembapan_saat_ini == data["target_kelembapan"])
	cek_kondisi_menang()


# =================================================================
# FUNGSI TESTING KEYBOARD
# =================================================================
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): 
		cek_kondisi_menang()
		
	if event.is_action_pressed("ui_focus_next"):
		simulasi_pipa_tersambung = true
		simulasi_suhu_sudah_pas = true
		simulasi_kelembapan_sudah_pas = true
		cek_kondisi_menang()
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			set_debit_air_simulasi("KECIL")
		elif event.keycode == KEY_2:
			simulasi_pipa_tersambung = true 
			set_debit_air_simulasi("SEDANG")
		elif event.keycode == KEY_3:
			set_debit_air_simulasi("BESAR")
