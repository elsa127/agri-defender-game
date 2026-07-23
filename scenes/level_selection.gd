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
	elif which == "level":
		if level_board_normal: level_board_normal.visible = false
		if level_board_active: level_board_active.visible = true
	elif which == "info":
		if info_board_normal: info_board_normal.visible = false
		if info_board_active: info_board_active.visible = true
