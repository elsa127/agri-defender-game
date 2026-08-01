extends Node

# --- DATA DOMPET & POIN ---
var poin_kamu: int = 120
var jumlah_hint: int = 0
var koin_sekarang: int = 0

const FILE_KOIN = "user://data_koin.save"

# Signal untuk memberi tahu UI bahwa data berubah
signal poin_berubah(poin_baru)
signal hint_berubah(hint_baru)
signal koin_berubah(koin_baru)

func _ready() -> void:
	muat_koin()

# --- FUNGSI SIMPAN & MUAT KOIN ---
func muat_koin() -> void:
	if FileAccess.file_exists(FILE_KOIN):
		var file = FileAccess.open(FILE_KOIN, FileAccess.READ)
		if file:
			koin_sekarang = file.get_as_text().to_int()
			file.close()
			koin_berubah.emit(koin_sekarang)

func simpan_koin() -> void:
	var file = FileAccess.open(FILE_KOIN, FileAccess.WRITE)
	if file:
		file.store_string(str(koin_sekarang))
		file.close()

func update_koin(jumlah_baru: int) -> void:
	koin_sekarang = jumlah_baru
	simpan_koin()
	koin_berubah.emit(koin_sekarang)

func tambah_koin(jumlah: int) -> void:
	koin_sekarang += jumlah
	simpan_koin()
	koin_berubah.emit(koin_sekarang)

# Fungsi untuk membeli hint
func beli_hint(jumlah_hint_dibeli: int, harga: int) -> bool:
	# Kamu bisa sinkronkan poin_kamu dengan koin_sekarang jika keduanya merujuk hal yang sama
	if koin_sekarang >= harga:
		koin_sekarang -= harga
		jumlah_hint += jumlah_hint_dibeli
		simpan_koin()
		
		# Beri tahu semua UI bahwa data berubah
		koin_berubah.emit(koin_sekarang)
		hint_berubah.emit(jumlah_hint)
		return true # Berhasil
	else:
		return false # Gagal (poin tidak cukup)

# --- SISTEM LEVEL UNLOCK/LOCK ---
var unlocked_level: int = 1
var current_level: int = 1

func complete_level(level_tersebut: int) -> void:
	# Jika menyelesaikan level 1 atau level berikutnya, buka level selanjutnya
	if level_tersebut >= unlocked_level:
		unlocked_level = level_tersebut + 1
		print("🎉 Level baru terbuka! Level aktif sekarang:", unlocked_level)

# --- TAMBAHAN FUNGSI PEMBANTU ---
# Fungsi untuk mengecek apakah suatu level sudah terbuka
func is_level_unlocked(level_num: int) -> bool:
	return level_num <= unlocked_level

# Fungsi untuk membuka level berikutnya saat menang
func unlock_next_level(level_yang_baru_menang: int) -> void:
	if level_yang_baru_menang >= unlocked_level:
		unlocked_level = level_yang_baru_menang + 1
		print("🔓 Level Baru Terbuka! Unlocked Level sekarang: ", unlocked_level)
