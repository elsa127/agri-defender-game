extends Node2D

# Slot untuk memasukkan gambar board secara visual lewat Inspector
@export var gambar_level_1: Texture2D
@export var gambar_level_2: Texture2D
@export var gambar_level_3: Texture2D

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

# Variabel penentu level yang aktif (biarkan di angka 2 untuk mengetes)
var level_sekarang: int = 1
var suhu_saat_ini: int = 0
var kelembapan_saat_ini: int = 0

func _ready() -> void:
	muat_level(level_sekarang)

func muat_level(nomor_level: int) -> void:
	if not DATA_LEVEL.has(nomor_level):
		return
		
	var data = DATA_LEVEL[nomor_level]
	
	# LOGIKA BARU: Mengganti gambar berdasarkan slot export yang diisi manual
	if nomor_level == 1 and gambar_level_1:
		$BoardLv1.texture = gambar_level_1
	elif nomor_level == 2 and gambar_level_2:
		$BoardLv1.texture = gambar_level_2
	elif nomor_level == 3 and gambar_level_3:
		$BoardLv1.texture = gambar_level_3
	
	suhu_saat_ini = data["suhu_awal"]
	kelembapan_saat_ini = data["kelembapan_awal"]
	
	print("====================================")
	print("BERHASIL MASUK: LEVEL ", nomor_level)
	print("Tanaman Level Ini: ", data["nama_tanaman"])
	print("====================================")
