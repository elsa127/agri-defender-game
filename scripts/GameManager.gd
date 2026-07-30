extends Node

# Data pemain (Dompet)
var poin_kamu: int = 120
var jumlah_hint: int = 0

# Signal untuk memberi tahu UI bahwa data berubah
signal poin_berubah(poin_baru)
signal hint_berubah(hint_baru)

# Fungsi untuk membeli hint
func beli_hint(jumlah_hint_dibeli: int, harga: int) -> bool:
	if poin_kamu >= harga:
		poin_kamu -= harga
		jumlah_hint += jumlah_hint_dibeli
		
		# Beri tahu semua UI bahwa data berubah
		poin_berubah.emit(poin_kamu)
		hint_berubah.emit(jumlah_hint)
		return true # Berhasil
	else:
		return false # Gagal (poin tidak cukup)
