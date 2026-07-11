extends Node2D

# Variabel untuk mencatat jenis tanaman aktif di level ini
var jenis_tanaman_aktif: String = "Padi"

# Fungsi ini dipanggil otomatis oleh GamePlay.gd saat level baru dimulai
func set_jenis_tanaman(nama_tanaman: String) -> void:
	jenis_tanaman_aktif = nama_tanaman
	sembunyikan_semua()
	
	# Memunculkan tanaman versi MENTAH sesuai target level
	match jenis_tanaman_aktif:
		"Padi":
			$PadiMentah.visible = true
		"Tomat Ceri":
			$TomatMentah.visible = true
		"Jagung":
			$JagungMentah.visible = true

# Fungsi untuk mengubah visual menjadi MATANG saat menang level
func ubah_ke_matang() -> void:
	sembunyikan_semua()
	
	match jenis_tanaman_aktif:
		"Padi":
			$PadiMatang.visible = true
		"Tomat Ceri":
			$TomatMatang.visible = true
		"Jagung":
			$JagungMatang.visible = true

# Fungsi untuk mengembalikan ke MENTAH jika syarat pipa/slider lepas kembali
func ubah_ke_mentah() -> void:
	set_jenis_tanaman(jenis_tanaman_aktif)

# Reset semua mata sprite menjadi mati (hidden)
func sembunyikan_semua() -> void:
	$PadiMentah.visible = false
	$PadiMatang.visible = false
	$TomatMentah.visible = false
	$TomatMatang.visible = false
	$JagungMentah.visible = false
	$JagungMatang.visible = false
