extends Sprite2D

# Menentukan derajat putaran (90 derajat sekali klik)
var rotation_step_degrees = 90

# Variabel "kunci" untuk mengecek apakah sedang dalam animasi
# Jika true, input klik akan diabaikan
var is_rotating = false

func _ready():
	# Memastikan poros rotasi berada tepat di tengah kepingan
	# (Jika gambar pipa kamu ukurannya 64x64, pastikan positionnya 0,0 
	# dan offset Spritenya diatur ke tengah).
	
	# Otomatis menyambungkan area klik ke fungsi pendeteksi input
	$Area2D.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	# Mengecek apakah inputnya klik kiri mouse, baru ditekan,
	# DAN kepingan TIDAK SEDANG berputar.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_rotating:
		rotate_piece()

func rotate_piece():
	# Aktifkan "kunci" agar klik berikutnya diabaikan
	is_rotating = true
	
	# Membuat animasi putaran yang halus (Tween) selama 0.2 detik
	# Durasi saya percepat sedikit agar terasa lebih responsif.
	var tween = get_tree().create_tween()
	
	# Menghitung target rotasi berdasarkan rotasi saat ini + 90.
	# Karena dikunci, target_rotation akan selalu tepat kelipatan 90.
	var target_rotation = rotation_degrees + rotation_step_degrees
	
	# Jalankan animasi
	tween.tween_property(self, "rotation_degrees", target_rotation, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# === BAGIAN TERPENTING: Membuka Kunci ===
	# Setelah animasi tween selesai, panggil fungsi '_on_rotation_finished'
	tween.finished.connect(_on_rotation_finished)

func _on_rotation_finished():
	# Membuka kembali "kunci" agar kepingan bisa diklik lagi
	is_rotating = false
	
	# Memastikan rotasi benar-benar tepat di angka kelipatan 90
	# Ini untuk mencegah error pembulatan kecil di sistem float Godot
	rotation_degrees = wrapf(round(rotation_degrees), 0, 360)
	if rotation_degrees == 360: rotation_degrees = 0
