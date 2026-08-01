extends Control

func _ready():
	print("=== MEMULAI ===")
	
	var toko_icon = _get_first_texture_button("TokoGroup")
	var level_icon = _get_first_texture_button("LevelGroup")
	var info_icon = _get_first_texture_button("InfoGroup")
	
	if toko_icon:
		toko_icon.pressed.connect(func(): set_active("toko"))
	if level_icon:
		level_icon.pressed.connect(func(): set_active("level"))
	if info_icon:
		info_icon.pressed.connect(func(): set_active("info"))
	
	call_deferred("set_active", "level")
	
	# Update status gembok/lock level saat scene dimuat
	update_level_status()

func _get_first_texture_button(group_name):
	var group = get_node_or_null(group_name)
	if not group:
		return null
	for child in group.get_children():
		if child is TextureButton:
			return child
		var found = _search_in_children(child)
		if found:
			return found
	return null

func _search_in_children(node):
	for child in node.get_children():
		if child is TextureButton:
			return child
		var found = _search_in_children(child)
		if found:
			return found
	return null

func set_active(which):
	# Cari semua icon
	var toko_icon = _get_first_texture_button("TokoGroup")
	var level_icon = _get_first_texture_button("LevelGroup")
	var info_icon = _get_first_texture_button("InfoGroup")
	
	var toko_board_normal = get_node_or_null("TokoGroup/TokoNamePlate/TokoBoardNormal")
	var toko_board_active = get_node_or_null("TokoGroup/TokoNamePlate/TokoBoardActive")
	
	var level_board_normal = get_node_or_null("LevelGroup/LevelNamePlate/LevelBoardNormal")
	var level_board_active = get_node_or_null("LevelGroup/LevelNamePlate/LevelBoardActive")
	
	var info_board_normal = get_node_or_null("InfoGroup/InfoNamePlate/InfoBoardNormal")
	var info_board_active = get_node_or_null("InfoGroup/InfoNamePlate/InfoBoardActive")
	
	# Reset semua papan ke normal (TANPA mengubah scale icon)
	if toko_board_normal: toko_board_normal.visible = true
	if toko_board_active: toko_board_active.visible = false
	
	if level_board_normal: level_board_normal.visible = true
	if level_board_active: level_board_active.visible = false
	
	if info_board_normal: info_board_normal.visible = true
	if info_board_active: info_board_active.visible = false
	
	# Set papan yang aktif (TANPA mengubah scale icon)
	if which == "toko":
		if toko_board_normal: toko_board_normal.visible = false
		if toko_board_active: toko_board_active.visible = true
		# Menampilkan Toko Hint
		if has_node("TokoHint"):
			$TokoHint.visible = true
			print("✅ Toko Hint dibuka!")
	elif which == "level":
		if level_board_normal: level_board_normal.visible = false
		if level_board_active: level_board_active.visible = true
	elif which == "info":
		if info_board_normal: info_board_normal.visible = false
		if info_board_active: info_board_active.visible = true
		# Menampilkan Info Popup
		if has_node("InfoPopup"):
			$InfoPopup.visible = true
			print("✅ Pop-up Info dibuka!")


func _on_toko_icon_pressed() -> void:
	# Tampilkan toko hint
	if has_node("TokoHint"):
		$TokoHint.visible = true
		print("✅ Toko Hint dibuka!")


func _on_info_icon_pressed() -> void:
	# Tampilkan pop-up info
	if has_node("InfoPopup"):
		$InfoPopup.visible = true
		print("✅ Pop-up Info dibuka!")


# Fungsi tambahan untuk menutup Info Popup (hubungkan ke tombol Close/X di InfoPopup)
func _on_close_button_pressed() -> void:
	if has_node("InfoPopup"):
		$InfoPopup.visible = false
		print("❌ Pop-up Info ditutup!")


func _on_close_info_pressed() -> void:
	if has_node("InfoPopup"):
		$InfoPopup.visible = false
		print("❌ Pop-up Info ditutup!")


# --- SISTEM UPDATE UNLOCK/LOCK LEVEL ---
func update_level_status() -> void:
	# Loop mengecek Level 1 sampai 9
	for i in range(1, 10):
		# Mencari node tombol kartu level (misal Level1Button, Level2Button, dst)
		var level_btn = get_node_or_null("Level" + str(i) + "Button")
		
		# Jika di scene kamu namanya beda (misal Level2Card / Level4Button),
		# fungsi di bawah ini akan otomatis mencoba mencari alternate name
		if not level_btn:
			level_btn = get_node_or_null("Level" + str(i) + "Card")
		
		if level_btn:
			var lock_overlay = level_btn.get_node_or_null("LockOverlay")
			var dark_overlay = level_btn.get_node_or_null("DarkOverlay")
			
			if i <= GameManager.unlocked_level:
				# Level Terbuka
				level_btn.disabled = false
				if lock_overlay: lock_overlay.visible = false
				if dark_overlay: dark_overlay.visible = false
			else:
				# Level Terkunci
				level_btn.disabled = true
				if lock_overlay: lock_overlay.visible = true
				if dark_overlay: dark_overlay.visible = true
