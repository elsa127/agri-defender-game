extends Control

# Ambil referensi ke Label yang menampilkan angka poin
@onready var label_angka_poin = $PapanKayu/LabelAngkaPoin

func _ready():
	# 1. Update tampilan poin saat toko pertama kali dibuka
	_update_tampilan_poin()
	
	# 2. Hubungkan tombol-tombol ke fungsinya
	var btn_tutup = $PapanKayu.get_node("BtnTutup")
	if btn_tutup and btn_tutup is TextureButton:
		btn_tutup.pressed.connect(_on_tutup_pressed)
	
	var btn_1 = $PapanKayu.get_node("BtnPoin1Hint")
	if btn_1 and btn_1 is TextureButton:
		btn_1.pressed.connect(_on_beli_1_hint)
	
	var btn_5 = $PapanKayu.get_node("BtnPoin5Hint")
	if btn_5 and btn_5 is TextureButton:
		btn_5.pressed.connect(_on_beli_5_hint)
	
	var btn_10 = $PapanKayu.get_node("BtnPoin10Hint")
	if btn_10 and btn_10 is TextureButton:
		btn_10.pressed.connect(_on_beli_10_hint)
	
	var btn_20 = $PapanKayu.get_node("BtnPoin20Hint")
	if btn_20 and btn_20 is TextureButton:
		btn_20.pressed.connect(_on_beli_20_hint)
	
	# 3. Dengarkan jika poin berubah, lalu update tampilan
	GameManager.poin_berubah.connect(_update_tampilan_poin)

# Fungsi untuk mengupdate teks di layar (PERBAIKAN: terima parameter)
func _update_tampilan_poin(poin_baru: int = -1):
	# Jika ada parameter poin_baru, gunakan itu
	# Jika tidak, ambil dari GameManager
	if poin_baru >= 0:
		label_angka_poin.text = str(poin_baru)
	else:
		label_angka_poin.text = str(GameManager.poin_kamu)

# Fungsi saat tombol X ditekan
func _on_tutup_pressed():
	self.visible = false # Sembunyikan toko

# Fungsi saat tombol beli ditekan
func _on_beli_1_hint():
	if GameManager.beli_hint(1, 25):
		print("✅ Beli 1 hint berhasil! Sisa poin: ", GameManager.poin_kamu)
	else:
		print("❌ Poin tidak cukup!")

func _on_beli_5_hint():
	if GameManager.beli_hint(5, 110):
		print("✅ Beli 5 hint berhasil! Sisa poin: ", GameManager.poin_kamu)
	else:
		print("❌ Poin tidak cukup!")

func _on_beli_10_hint():
	if GameManager.beli_hint(10, 200):
		print("✅ Beli 10 hint berhasil! Sisa poin: ", GameManager.poin_kamu)
	else:
		print("❌ Poin tidak cukup!")

func _on_beli_20_hint():
	if GameManager.beli_hint(20, 350):
		print("✅ Beli 20 hint berhasil! Sisa poin: ", GameManager.poin_kamu)
	else:
		print(" Poin tidak cukup!")


func _on_close_button_pressed() -> void:
	self.visible = false # Menyembunyikan node TokoHint (mengikuti fungsi tombol tutup di atasnya)
	print("❌ Toko Hint ditutup melalui _on_close_button_pressed!")
