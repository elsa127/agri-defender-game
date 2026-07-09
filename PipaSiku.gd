extends Sprite2D

# Variabel untuk menentukan arah putaran (90 derajat)
const ROTATION_STEP = 90

func _ready() -> void:
	# Menghubungkan signal 'input_event' dari node Area2D
	# Ini memberitahu script saat ada klik mouse atau sentuhan di area pipa
	$Area2D.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Cek apakah input yang masuk adalah klik tombol kiri mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Jika diklik, putar objek sebesar ROTATION_STEP (90 derajat)
		rotation_degrees += ROTATION_STEP
		
		# Jika putaran mencapai atau lebih dari 360, kembalikan ke 0
		if rotation_degrees >= 360:
			rotation_degrees = 0
			
		print("Pipa Siku diketuk! Posisi derajat sekarang: ", rotation_degrees)
