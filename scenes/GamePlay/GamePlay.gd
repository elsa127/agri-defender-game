extends Node2D

const DATA_LEVEL = {
	1: {
		"gambar_board": "res://asset_gambar/gambar_button/board_lv_1.png",
		"nama_tanaman": "Padi",
		"ukuran_grid": "2x2",
		"target_suhu": 30,
		"target_kelembapan": 60,
		"suhu_awal": 45,
		"kelembapan_awal": 20
	},
	2: {
		"gambar_board": "res://asset_gambar/gambar_button/board_lv_2.png",
		"nama_tanaman": "Tomat Ceri",
		"ukuran_grid": "3x3",
		"target_suhu": 24,
		"target_kelembapan": 75,
		"suhu_awal": 15,
		"kelembapan_awal": 90
	},
	3: {
		"gambar_board": "res://asset_gambar/gambar_button/board_lv_3.png",
		"nama_tanaman": "Jagung",
		"ukuran_grid": "3x3",
		"target_suhu": 28,
		"target_kelembapan": 55,
		"suhu_awal": 50,
		"kelembapan_awal": 10
	}
}

var level_sekarang: int = 1
var suhu_saat_ini: int = 0
var kelembapan_saat_ini: int = 0

func _ready() -> void:
	muat_level(level_sekarang)

func muat_level(nomor_level: int) -> void:
	if not DATA_LEVEL.has(nomor_level):
		print("Level ", nomor_level, " belum terdaftar!")
		return
		
	var data = DATA_LEVEL[nomor_level]
	
	var tekstur_baru = load(data["gambar_board"])
	if tekstur_baru:
		$PapanLevel.texture = tekstur_baru
	
	suhu_saat_ini = data["suhu_awal"]
	kelembapan_saat_ini = data["kelembapan_awal"]
	
	print("====================================")
	print("BERHASIL MASUK: LEVEL ", nomor_level)
	print("Tanaman Level Ini: ", data["nama_tanaman"])
	print("Ukuran Kotak Grid: ", data["ukuran_grid"])
	print("------------------------------------")
	print("KONDISI TANTANGAN AWAL:")
	print("Suhu Sekarang     : ", suhu_saat_ini, "°C (Harusnya pas: ", data["target_suhu"], "°C)")
	print("Kelembapan Sekarang: ", kelembapan_saat_ini, "% (Harusnya pas: ", data["target_kelembapan"], "%)")
	print("====================================")
