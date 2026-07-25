extends Node2D

# --- VARIABEL ROTASI ---
var rotation_step_degrees = 90
var is_rotating = false

# --- VARIABEL EFEK HINT / NYUT-NYUT ---
var sudah_pernah_diputar: bool = false
var tween_nyut: Tween
var sedang_nyut: bool = false
var skala_asli: Vector2 = Vector2.ZERO


func _ready():
	# Menyambungkan area klik ke fungsi pendeteksi input
	if has_node("Area2D"):
		$Area2D.input_event.connect(_on_area_2d_input_event)


func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_rotating:
		rotate_piece()


func rotate_piece():
	is_rotating = true
	
	# Matikan nyut-nyut jika pemain memutar pipa ini sendiri secara manual
	hentikan_nyut_nyut()
	catat_interaksi_pemain()
	
	var tween = get_tree().create_tween()
	var target_rotation = rotation_degrees + rotation_step_degrees
	
	tween.tween_property(self, "rotation_degrees", target_rotation, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_rotation_finished)


func _on_rotation_finished():
	is_rotating = false
	rotation_degrees = wrapf(round(rotation_degrees), 0, 360)
	if rotation_degrees == 360:
		rotation_degrees = 0


# --- FUNGSI TANDAI INTERAKSI ---
func catat_interaksi_pemain() -> void:
	sudah_pernah_diputar = true


# --- LOGIKA HINT & NYUT-NYUT ---

# 1. Mulai nyut-nyut (Diperintahkan oleh game_play.gd ketika SEMUA pipa sudah diputar & pipa ini masih salah)
func mulai_nyut_nyut() -> void:
	if sedang_nyut:
		return
		
	sedang_nyut = true
	
	# Simpan skala asli pipa (misal 1.9, 1.4, atau 1.0) jika belum disimpan
	if skala_asli == Vector2.ZERO:
		skala_asli = scale
	
	if has_node("Sprite2D"): $Sprite2D.centered = true
	elif has_node("Sprite"): $Sprite.centered = true
	
	tween_nyut = create_tween().set_loops()
	# Animasi membesar ke 1.15x dari skala aslinya, lalu kembali ke skala asli
	tween_nyut.tween_property(self, "scale", skala_asli * 1.15, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_nyut.tween_property(self, "scale", skala_asli, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


# 2. Hentikan nyut-nyut dan kembalikan skala ke SKALA ASLI
func hentikan_nyut_nyut() -> void:
	if not sedang_nyut:
		return
		
	sedang_nyut = false
	
	if tween_nyut and tween_nyut.is_running():
		tween_nyut.kill()
		
	if skala_asli == Vector2.ZERO:
		skala_asli = scale
		
	var tween_reset = create_tween()
	# Reset skala kembali ke skala asli (bukan Vector2.ONE)
	tween_reset.tween_property(self, "scale", skala_asli, 0.15)


# 3. Dipanggil SAAT TOMBOL HINT DIKLIK: Hentikan nyut-nyut & Putar Otomatis
func putar_otomatis_via_hint() -> void:
	sudah_pernah_diputar = true
	hentikan_nyut_nyut()
	
	if has_meta("rotasi_benar"):
		var rotasi_target = float(get_meta("rotasi_benar"))
		var tween_putar = create_tween()
		tween_putar.tween_property(self, "rotation_degrees", rotasi_target, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
