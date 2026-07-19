extends Node2D

var jenis_sekarang: String = ""

func _ready() -> void:
	# Cek apakah GamePlay sudah mengatur jenis tanaman. 
	# Jika sudah, tampilkan yang mentah. Jika belum, sembunyikan semua.
	if jenis_sekarang != "":
		ubah_ke_mentah()
	else:
		sembunyikan_semua()

func set_jenis_tanaman(nama_tanaman: String) -> void:
	jenis_sekarang = nama_tanaman
	ubah_ke_mentah()

func ubah_ke_mentah() -> void:
	sembunyikan_semua()
	match jenis_sekarang:
		"Padi":
			$PadiMentah.visible = true
		"Tomat Ceri":
			$TomatMentah.visible = true
		"Jagung":
			$JagungMentah.visible = true

func ubah_ke_matang() -> void:
	sembunyikan_semua()
	match jenis_sekarang:
		"Padi":
			$PadiMatang.visible = true
		"Tomat Ceri":
			$TomatMatang.visible = true
		"Jagung":
			$JagungMatang.visible = true

func sembunyikan_semua() -> void:
	$PadiMentah.visible = false
	$PadiMatang.visible = false
	$TomatMentah.visible = false
	$TomatMatang.visible = false
	$JagungMentah.visible = false
	$JagungMatang.visible = false
