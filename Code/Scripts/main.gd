extends Node2D

var time_count = 0

# Stores the id for the tileset
var tile_id: int = 2

# Stores the id for the tileset with the special tiles
var special_id: int = 3

# Stores the size of the board
var width = 8
var height = width

# Stores the offset of the grid from the origin
var grid_pos = Vector2i(1,1)

# Stores the position of the top left placable tile
var top_left = grid_pos + Vector2i(1,1)

# Stores the initial size of an individual tile before scaling has taken place
var tile_size = 32
# Stores the size an individual tile after scaling has taken place
var scaled_tile_size

# Stores the tile that the grid is made of
var grid_colour = Vector2i(14, 0)

var dragging_piece_offset

# Stores the coordinates of bomb blocks
#var bomb_coords = []

var score = 0

# Need to fix:
# 	Able to place tiles outside of play area --
# 	When a new piece is the same as a another one you currently hold, the other one gets rotated to match the rotation --
# 	Centering of particles emitted when line is cleared --

var particle_scene = preload("res://Code/Scenes/burst_particle.tscn")
var tile_ray_scene = preload("res://Code/Scenes/tile_ray.tscn")
var explode_particle_scene = preload("res://Code/Scenes/explode_effect.tscn")


var l_piece: Piece = Piece.new([2, 4, 4])
var j_piece: Piece = Piece.new([6, 4, 4])
var t_piece: Piece = Piece.new([2, 4, 1])
var o_piece: Piece = Piece.new([2,4,6])
var s_piece: Piece = Piece.new([6,4,6])
var z_piece: Piece = Piece.new([2,4,2])
var line_piece: Piece = Piece.new([2,2,2])


var nine_piece: Piece = Piece.new([4, 4, 2, 0, 0, 2, 4, 4])
var six_piece: Piece = Piece.new([2,2,4,6,6])
var three_piece: Piece = Piece.new([2,2])
var two_piece: Piece = Piece.new([2])

var big_rangle_piece: Piece = Piece.new([4,4,2,2])
var h_piece: Piece = Piece.new([4,4,1,1,4,4])
var n_piece: Piece = Piece.new([2,4,4,6])
var big_t_piece: Piece = Piece.new([2,2,5,4])
var rangle_piece: Piece = Piece.new([2,4])

var bomb_piece: Piece = Piece.new([], Vector2i(16,0), Piece.SpecialTiles.BOMB, false)
var line_bomb_piece: Piece = Piece.new([], Vector2i(16,0), Piece.SpecialTiles.LINE, false)

var error_piece: Piece = Piece.new([])

var possible_pieces: Array[Piece] = [l_piece, j_piece, t_piece, o_piece, s_piece, z_piece, line_piece, nine_piece, six_piece,
three_piece, two_piece, big_rangle_piece, h_piece, n_piece, big_t_piece, rangle_piece, bomb_piece, line_bomb_piece]


var current_pieces = []

var pieces: Array[Piece] = [null, null, null]

var rotations = [Piece.Rotation.NORTH, Piece.Rotation.SOUTH, Piece.Rotation.WEST, Piece.Rotation.EAST]

# Keeps track of whether a piece is being dragged currently or not
var dragging = false

# The piece that is currently being dragged
var dragging_piece: Piece

# The slot that is currently being used
var dragging_slot
# Initial position of Move layer
var default_position

# Draws the three main pieces
func draw_pieces(slots = [0,1,2]):
	if 0 in slots:
		draw_piece_offset(pieces[0], Vector2i(1,1), pieces[0].colour, $Selection)
	if 1 in slots:
		draw_piece_offset(pieces[1], Vector2i(6,1), pieces[1].colour, $Selection)
	if 2 in slots:
		draw_piece_offset(pieces[2], Vector2i(11,1), pieces[2].colour, $Selection)

# Derives the cell offsets from the a chain code value
func get_index_offset_from_chain_code(code: int):
	var output: Vector2i
	assert(code <= 7 && code >= 0, "ERROR: You must give a value between 0 and 7");
	match code:
		0:
			output = Vector2i(0, -1)
		1:
			output = Vector2i(1, -1)
		2:
			output = Vector2i(1, 0)
		3:
			output = Vector2i(1, 1)
		4:
			output = Vector2i(0, 1)
		5:
			output = Vector2i(-1, 1)
		6:
			output = Vector2i(-1, 0)
		7:
			output = Vector2i(-1, -1)
	return output

# Gets the offset that a piece needs to be drawn at so it never goes beyond the top left spot
func find_piece_offset(chain: Array, pos: Vector2i):
	var original_pos: Vector2i = pos
	var min_x = pos.x
	var min_y = pos.y
	for i in chain:
		pos += get_index_offset_from_chain_code(i)
		min_x = min(min_x, pos.x)
		min_y = min(min_y, pos.y)
	var offset = Vector2i(original_pos.x - min_x, original_pos.y - min_y)
	return offset


# Draws a piece specified by a chain code
func draw_piece(piece: Piece, pos: Vector2i, colour: Vector2i, layer: TileMapLayer, tile_source_id=tile_id):
	
	layer.set_cell(pos, tile_source_id, colour)
	for i in piece.chain_code:
		pos += get_index_offset_from_chain_code(i)
		layer.set_cell(pos, tile_source_id, colour)

# Draws a piece that uses special tiles
func draw_special_piece(piece: Piece, pos: Vector2i, special: Piece.SpecialTiles, layer: TileMapLayer):
	layer.set_cell(pos, special_id, Vector2i.ZERO, piece.special)
	for i in piece.chain_code:
		pos += get_index_offset_from_chain_code(i)
		layer.set_cell(pos, special_id, Vector2i.ZERO, piece.special)

# Draws a piece using the offset
func draw_piece_offset(piece: Piece, pos: Vector2i, colour: Vector2i, layer: TileMapLayer, tile_source_id=tile_id):
		pos += find_piece_offset(piece.chain_code, pos)
		if piece.special == Piece.SpecialTiles.NONE:
			draw_piece(piece, pos, colour, layer, tile_source_id)
		else:
			draw_special_piece(piece, pos, piece.special, layer)


# Clears a rectangular area
func clear_area(pos: Vector2i, width, height, layer: TileMapLayer):
	var start_pos = pos
	for i in range(width):
		for j in range(height):
			pos = start_pos + Vector2i(i,j)
			layer.erase_cell(pos)

# Clears an area specified by a chain code
func clear_chain(pos: Vector2i, chain_code: Array[int], layer: TileMapLayer):
	layer.erase_cell(pos)
	for i in chain_code:
		pos += get_index_offset_from_chain_code(i)
		layer.erase_cell(pos)

# Checks if a chain code can fit in a specific position
func check_chain(pos: Vector2i, chain_code: Array, layer: TileMapLayer):
	var output = true
	if layer.get_cell_atlas_coords(pos) == Vector2i(-1,-1):
		for i in chain_code:
			pos += get_index_offset_from_chain_code(i)
			if ! layer.get_cell_atlas_coords(pos) == Vector2i(-1,-1):
				output = false
				break
	else:
		output = false
	return output

# Checks if a piece fits using the offset drawing as well
func check_chain_offset(pos: Vector2i, chain_code: Array, layer: TileMapLayer):
	pos += find_piece_offset(chain_code, pos)
	return check_chain(pos, chain_code, layer)
	
# Checks if the lines need clearing
func check_lines():
	var rows: Array
	var columns: Array
	var passed = true
	for i in range(width):
		passed = true
		for j in range(height):
			passed = $Placed.get_cell_atlas_coords(top_left + Vector2i(i,j)) != Vector2i(-1,-1)
			if ! passed:
				break
		if passed:
			columns.append(i)
	
	for j in range(width):
		passed = true
		for i in range(height):
			passed = $Placed.get_cell_atlas_coords(top_left + Vector2i(i,j)) != Vector2i(-1,-1)
			if ! passed:
				break
		if passed:
			rows.append(j)
	
	score += (rows.size() + columns.size()) * 100
	
	
	for i in columns:
		gen_ray(TileRay.Direction.VERTICAL, Vector2i(i, 0))
		var particle = particle_scene.instantiate()
		particle.global_position = $Placed.to_global($Placed.map_to_local(top_left + Vector2i(i, width/2)))
		if width % 2 == 0:
			particle.global_position.y -= $Placed.scale.y * tile_size / 2 
		add_sibling(particle)
		particle.start()
		$Camera.shakeTimed(0.2)
		for j in height:
			$Placed.erase_cell(top_left + Vector2i(i, j))
			#if top_left + Vector2i(i,j) in bomb_coords:
				#bomb_coords.erase(top_left + Vector2i(i,j))
		
	for j in rows:
		gen_ray(TileRay.Direction.HORIZONTAL, Vector2i(0, j))
		
		var particle: Node2D = particle_scene.instantiate()
		
		particle.global_position = $Placed.to_global($Placed.map_to_local(top_left + Vector2i(height/2, j)))
		if height % 2 == 0:
			particle.global_position.x -= $Placed.scale.x * tile_size / 2 
		
		particle.rotate_particles(90)
		add_sibling(particle)
		$Camera.shakeTimed(0.2)
		particle.start()
		for i in width:
			$Placed.erase_cell(top_left + Vector2i(i, j))
			#if top_left + Vector2i(i,j) in bomb_coords:
				#bomb_coords.erase(top_left + Vector2i(i,j))

# Checks if it given piece can be placed anywhere on the grid
func check_if_piece_placable(piece: Piece):
	var output = false
	
	
	for x in range(width):
		for y in range(height):
			if check_chain_offset(Vector2i(x,y) + grid_pos, piece.chain_code, $Placed):
				output = true
	return output

func _ready():
	scaled_tile_size = $Placed.tile_set.tile_size.x * $Placed.scale.x
	#print(scaled_tile_size)
	#create_board()
	for i in range(3):
		pieces[i] = get_random_piece()
	draw_pieces()
	default_position = $Move.global_position
	for node in $MusicTiles.get_children():
		node.connect("lose_game", game_lose)



func _process(delta: float):
	$ScoreLabel.text = "Score: " + str(score)
	var cell_coords
	var width
	if dragging:
		$Move.global_position = get_global_mouse_position()
		$Ghost.clear()

		$Move.global_position.x -= dragging_piece_offset
		cell_coords = $Ghost.local_to_map($Ghost.to_local($Move.global_position))
		cell_coords.y -= 3
		$Move.global_position -= ($Ghost.map_to_local(Vector2i(0,3)))

		if 2 <= cell_coords.x and cell_coords.x <= 9 and 2 <= cell_coords.y and cell_coords.y <= 9: 
			if check_chain_offset(cell_coords, dragging_piece.chain_code, $Placed):
				draw_piece_offset(dragging_piece, cell_coords, dragging_piece.colour + Vector2i(0,1), $Ghost)
		
		
		if Input.is_action_just_released("left_click"):
			if check_chain_offset(cell_coords, dragging_piece.chain_code, $Placed) and 2 <= cell_coords.x and cell_coords.x <= 9 and 2 <= cell_coords.y and cell_coords.y <= 9:
				draw_piece_offset(dragging_piece, cell_coords, dragging_piece.colour, $Placed)
				#if dragging_piece.can_explode:
					#bomb_coords.append(cell_coords)
				pieces[dragging_slot] = get_random_piece()
				check_lines()
			dragging = false
			$Move.global_position = default_position
			$Ghost.clear()
			let_go()



func let_go():
	dragging_piece = null
	dragging_slot = null
	draw_pieces()
	clear_area(Vector2i(0,0), 4, 4, $Move)


func _on_area_1_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		move_piece(pieces[0], 0)

func _on_area_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		move_piece(pieces[1], 1)

func _on_area_3_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		move_piece(pieces[2], 2)


func clear_slot(slot):
	match slot:
		0:
			clear_area(Vector2i(1,1), 4, 4, $Selection)
		1:
			clear_area(Vector2i(6,1), 4, 4, $Selection)
		2:
			clear_area(Vector2i(11,1), 4, 4, $Selection)


func move_piece(piece, slot):
	dragging_piece = piece
	dragging_slot = slot
	dragging = true
	dragging_piece_offset = ((dragging_piece.get_width() * 0.5) - 0.5) * scaled_tile_size
	update_move_piece()
	clear_slot(slot)

func update_move_piece():
	if dragging_piece != null:
		clear_area(Vector2i(0,0), 4, 4, $Move)
		draw_piece_offset(dragging_piece, Vector2i(0,0), dragging_piece.colour, $Move)
		dragging_piece_offset = ((dragging_piece.get_width() * 0.5) - 0.5) * scaled_tile_size
		
	

# When a new piece is rotated, the old one is rotated due to how godot passed objects by reference
# Fixed
func get_random_piece():
	if not current_pieces.is_empty():
		current_pieces.shuffle()
	else:
		current_pieces = possible_pieces.duplicate()
		
	var piece: Piece = current_pieces.pop_front().clone()
	piece.rotate(rotations.pick_random())
	if check_if_piece_placable(piece):
		return piece
	else:
		var piece_list = possible_pieces.duplicate()
		piece_list.shuffle()
		var random_rotations = rotations.duplicate()
		random_rotations.shuffle()
		
		for p in piece_list:
			for rotation in random_rotations:
				piece = p.clone()
				piece.rotate(rotation)
				if check_if_piece_placable(piece):
					return piece
		piece = error_piece.clone()
		return piece




# Function to create the board based on the width and height values
# Scales board to fit in the 
func create_board():
	for i in range(width+2):
		$Placed.set_cell(Vector2i(i,0) + grid_pos, tile_id, grid_colour)
		$Placed.set_cell(Vector2i(i,height+1) + grid_pos, tile_id, grid_colour)
	for i in range(height+2):
		$Placed.set_cell(Vector2i(0,i) + grid_pos, tile_id, grid_colour)
		$Placed.set_cell(Vector2i(width+1,i) + grid_pos, tile_id, grid_colour)
	var edge_coords = $Placed.to_global($Placed.map_to_local(Vector2i(width+2,0) + grid_pos)).x - tile_size / 2
	var screen_edge = get_viewport().content_scale_size.x
	var scale = screen_edge / edge_coords
	$Placed.scale = Vector2(scale, scale)
	$Move.scale = Vector2(scale, scale)
	$Ghost.scale = Vector2(scale, scale)
	
	var bottom_placed_coords = $Placed.to_global($Placed.map_to_local(Vector2i(0, height + 2) + grid_pos)).y - (tile_size / 2) - 3
	#var top_selection_coords = $Selection.to_global($Selection.map_to_local(Vector2i()))
	#print(bottom_placed_coords)
	$Selection.global_position.y = bottom_placed_coords
	
	#print($Placed.to_global($Placed.map_to_local(Vector2i(width+2,1))).x)
	print(scale)


func gen_ray(direction: TileRay.Direction, coords: Vector2i) -> void:
	var pos = $Placed.to_global($Placed.map_to_local(coords + top_left))
	var ray = tile_ray_scene.instantiate()
	ray.set_direction(direction)
	#print(pos)
	#if direction == TileRay.Direction.VERTICAL:
	ray.global_position = pos
	add_child(ray)



func _on_music_clock_timeout() -> void:
	time_count += 1
	time_count %= 4
	
	for node in $MusicTiles.get_children():
		if node is Tiles:
			node.clock_timeout()
		
	for node: Special in $Placed.get_children():
		node.timeout()
	#for coord in bomb_coords:
		#var particle = explode_particle_scene.instantiate()
		#particle.global_position = $Placed.to_global($Placed.map_to_local(coord))
		#add_sibling(particle)
		#particle.restart()
		#$Camera.shakeTimed(0.2)
		#for i in range(coord.x-1, coord.x+2):
			#for j in range(coord.y-1, coord.y+2):
				#if 2 <= i and i <= 9 and 2 <= j and j <= 9:
					#$Placed.erase_cell(Vector2i(i,j))
	#bomb_coords.clear()



func bomb_expl(coords: Vector2i):
	var particle = explode_particle_scene.instantiate()
	particle.global_position = $Placed.to_global($Placed.map_to_local(coords))
	add_sibling(particle)
	particle.restart()
	$Camera.shakeTimed(0.2)
	for i in range(coords.x-1, coords.x+2):
		for j in range(coords.y-1, coords.y+2):
			if top_left.x <= i and i <= top_left.x + width - 1 and top_left.y <= j and j <= top_left.y + height - 1:
				$Placed.erase_cell(Vector2i(i,j))

func line_expl(coords: Vector2i, vertical: bool):
	if vertical:
		for i in range(top_left.y, top_left.y + height):
			$Placed.erase_cell(Vector2i(coords.x, i))
	else:
		for i in range(top_left.x, top_left.x + width):
			$Placed.erase_cell(Vector2i(i, coords.y))


func _on_beat_timer_timeout() -> void:
	for piece: Piece in pieces:
		piece.relative_rotate(Piece.RelativeRotation.RIGHT)
	
	if dragging_slot == 0:
		clear_slot(1)
		clear_slot(2)
	elif dragging_slot == 1:
		clear_slot(0)
		clear_slot(2)
	elif dragging_slot == 2:
		clear_slot(0)
		clear_slot(1)
	else:
		clear_slot(0)
		clear_slot(1)
		clear_slot(2)
	var array = [0,1,2]
	array.erase(dragging_slot)
	draw_pieces(array)
	update_move_piece()
	
	


func _on_can_lose_timer_timeout() -> void:
	for node in $MusicTiles.get_children():
		if node is Tiles:
			node.can_lose = true

func game_lose():
	print("Fuck you, you lose")


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
