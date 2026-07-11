extends Node2D

# Slot Export Visual untuk Gambar Board Level (Godot 4.x)
@export var gambar_level_1: Texture2D
@export var gambar_level_2: Texture2D
@export var gambar_level_3: Texture2D

# Load aset gambar musik hidup/mati
@onready var gambar_musik_hidup = preload("res://asset_gambar/gambar_button/button_musik_hidup.png")
@onready var gambar_musik_mati = preload("res://asset_gambar/gambar_button/button_musik_mati.png")

const DATA_LEVEL = {
	1: {
		"nama_tanaman": "Padi",
		"ukuran_grid": "2x2",
		"target_suhu": 30,
		"target_kelembapan": 60,
		"suhu_awal": 45,
		"kelembapan_awal": 20
	},
	2: {
		"nama_tanaman": "Tomat Ceri",
		"ukuran_grid": "3x3",
		"target_suhu": 24,
		"target_kelembapan": 75,
		"suhu_awal": 15,
		"kelembapan_awal": 90
	},
	3: {
		"nama_tanaman": "Jagung",
		"ukuran_grid": "3x3",
		"target_suhu": 28,
		"target_kelembapan": 55,
		"suhu_awal": 50,
		"kelembapan_awal": 10
	}
}

# Manajemen Level & Status
var level_sekarang: int = 1
var suhu_saat_ini: int = 0
var kelembapan_saat_ini: int = 0

# Sistem Koin
var koin_sekarang: int = 0
var target_koin: int = 120

# Saklar Musik
var musik_aktif: bool = true

# =================================================================
# SAKLAR LOGIKA SIMULASI (TUGAS LANGKAH 5)
# =================================================================
# Karena langkah 3 & 4 belum selesai dikerjakan temanmu, ubah variabel 
# di bawah ini menjadi true/false secara manual untuk mengetes sistemmu!
var simulasi_pipa_tersambung: bool = false
var simulasi_suhu_sudah_pas: bool = false
var simulasi_kelembapan_sudah_pas: bool = false


func _ready() -> void:
	muat_level(level_sekarang)


func muat_level(nomor_level: int) -> void:
	if not DATA_LEVEL.has(nomor_level):
		return
		
	var data = DATA_LEVEL[nomor_level]
	
	# Mengganti gambar board berdasarkan slot export di Inspector
	if nomor_level == 1 and gambar_level_1:
		$BoardLv1.texture = gambar_level_1
	elif nomor_level == 2 and gambar_level_2:
		$BoardLv1.texture = gambar_level_2
	elif nomor_level == 3 and gambar_level_3:
		$BoardLv1.texture = gambar_level_3
	
	suhu_saat_ini = data["suhu_awal"]
	kelembapan_saat_ini = data["kelembapan_awal"]
	
	# Update tampilan awal koin saat level dimuat
	$InterfaceUI/PnlKoin/TxtKoin.text = str(koin_sekarang) + "/" + str(target_koin)
	
	print("====================================")
	print("BERHASIL MASUK: LEVEL ", nomor_level)
	print("Tanaman Level Ini: ", data["nama_tanaman"])
	print("====================================")


# =================================================================
# LOGIKA TOMBOL MUSIK
# =================================================================
func _on_btn_musik_pressed() -> void:
	# Balikkan status saklar (On jadi Off, Off jadi On)
	musik_aktif = not musik_aktif
	
	if musik_aktif:
		$InterfaceUI/BtnMusik.texture_normal = gambar_musik_hidup
		print("Musik Menyala")
	else:
		$InterfaceUI/BtnMusik.texture_normal = gambar_musik_mati
		print("Musik Dimatikan")


# =================================================================
# LOGIKA CEK KEMENANGAN & KOIN (LANGKAH 5)
# =================================================================
func cek_kondisi_menang() -> void:
	# Memeriksa 3 syarat kemenangan (sementara menggunakan saklar simulasi)
	if simulasi_pipa_tersambung and simulasi_suhu_sudah_pas and simulasi_kelembapan_sudah_pas:
		pemicu_menang_level()
	else:
		print("Belum menang. Periksa kembali pipa atau slider UI kamu!")


func pemicu_menang_level() -> void:
	print("Selamat! Kamu Menang!")
	$PapanSelamat.visible = true # Memunculkan papan kemenangan di layar
	
	# Setiap kali menang level, hadiah koin bertambah 40 poin
	koin_sekarang += 40
	
	# Batasi agar koin tidak melebihi target maksimal game
	if koin_sekarang > target_koin:
		koin_sekarang = target_koin
		
	# Perbarui teks koin di layar secara otomatis
	$InterfaceUI/PnlKoin/TxtKoin.text = str(koin_sekarang) + "/" + str(target_koin)
	print("Koin bertambah! Koin saat ini: ", koin_sekarang)


# Fungsi mendengarkan tombol keyboard (Untuk tes mandiri tanpa slider & pipa)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): # Tombol SPASI
		print("--- MENCOBA TES CEK KEMENANGAN ---")
		cek_kondisi_menang()
