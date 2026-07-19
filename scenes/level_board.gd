extends TextureRect

func _ready():
	# Set ukuran papan (sesuaikan dengan desain)
	var board_width = 430
	var board_height = 700
	
	# Set scale agar sesuai ukuran yang diinginkan
	var original_width = texture.get_width()
	var original_height = texture.get_height()
	
	var scale_x = board_width / original_width
	var scale_y = board_height / original_height
	scale = Vector2(scale_x, scale_y)
	
	# Set posisi di tengah layar
	var viewport_size = get_viewport().get_visible_rect().size
	position.x = (viewport_size.x - board_width) / 2
	position.y = 150  # Jarak dari atas (sesuaikan)
