extends Node2D




var tile_id: int = 1

var width = 14
var height = 14

var top_left = Vector2i(1,2)



# Need to fix:
# 	Able to place tiles outside of play area
# 	When a new piece is the same as a another one you currently hold, the other one gets rotated to match the rotation


var l_piece: Piece = Piece.new([2, 4, 4], Vector2i(4,0))
var j_piece: Piece = Piece.new([6, 4, 4], Vector2i(5,0))
var t_piece: Piece = Piece.new([2, 4, 1], Vector2i(1,0))
var o_piece: Piece = Piece.new([2,4,6], Vector2i(2,0))
var s_piece: Piece = Piece.new([6,4,6], Vector2i(4,0))
var z_piece: Piece = Piece.new([2,4,2], Vector2i(3,0))
var line_piece: Piece = Piece.new([2,2,2], Vector2i(0,0))


var nine_piece: Piece = Piece.new([4, 4, 2, 0, 0, 2, 4, 4], Vector2i(3,0))
var six_piece: Piece = Piece.new([2,2,4,6,6], Vector2i(2,0))
var three_piece: Piece = Piece.new([2,2], Vector2i(1,0))
var two_piece: Piece = Piece.new([2], Vector2i(0,0))

var big_rangle_piece: Piece = Piece.new([4,4,2,2], Vector2i(5,0))
var h_piece: Piece = Piece.new([4,4,1,1,4,4], Vector2i(4,0))
var n_piece: Piece = Piece.new([2,4,4,6], Vector2i(3,0))
var big_t_piece: Piece = Piece.new([2,2,5,4], Vector2i(3,0))
var rangle_piece: Piece = Piece.new([2,4], Vector2i(1,0))


var possible_pieces: Array[Piece] = [l_piece, j_piece, t_piece, o_piece, s_piece, z_piece, line_piece, nine_piece, six_piece,
three_piece, two_piece, big_rangle_piece, h_piece, n_piece, big_t_piece, rangle_piece]

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
func draw_pieces():
	draw_piece_offset(pieces[0], Vector2i(1,17), pieces[0].colour, $Placed)
	draw_piece_offset(pieces[1], Vector2i(6,17), pieces[1].colour, $Placed)
	draw_piece_offset(pieces[2], Vector2i(11,17), pieces[2].colour, $Placed)

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
func draw_piece(piece: Piece, pos: Vector2i, colour: Vector2i, layer: TileMapLayer):
	layer.set_cell(pos, tile_id, colour)
	for i in piece.chain_code:
		pos += get_index_offset_from_chain_code(i)
		layer.set_cell(pos, tile_id, colour)

func draw_piece_offset(piece: Piece, pos: Vector2i, colour: Vector2i, layer: TileMapLayer):
		pos += find_piece_offset(piece.chain_code, pos)
		draw_piece(piece, pos, colour, layer)


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
	else:
		output = false
	return output

func check_chain_offset(pos: Vector2i, chain_code: Array, layer: TileMapLayer):
	pos += find_piece_offset(chain_code, pos)
	return check_chain(pos, chain_code, layer)
	


func _ready():
	for i in range(3):
		pieces[i] = get_random_piece()
	draw_pieces()
	default_position = $Move.global_position



func _process(delta: float):
	var cell_coords
	if dragging:
		#print("hello")
		
		$Move.global_position = get_global_mouse_position()
		#$Move.global_position.y -= 32 * 2
		$Ghost.clear()
		
		cell_coords = $Ghost.local_to_map($Ghost.to_local(get_global_mouse_position()))
		cell_coords.y -= 3

		$Move.global_position -= ($Ghost.map_to_local(Vector2i(0,2)))
		if check_chain_offset(cell_coords, dragging_piece.chain_code, $Placed):
			
			draw_piece_offset(dragging_piece, cell_coords, Vector2i(12,0), $Ghost)
			
		
		
		if Input.is_action_just_released("left_click"):
			if check_chain_offset(cell_coords, dragging_piece.chain_code, $Placed):
				draw_piece_offset(dragging_piece, cell_coords, dragging_piece.colour, $Placed)
				pieces[dragging_slot] = get_random_piece()
				check_lines()
			dragging = false
			$Move.global_position = default_position
			$Ghost.clear()
			let_go()
			

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
	
	for i in columns:
		for j in height:
			$Placed.erase_cell(top_left + Vector2i(i, j))
	
	for j in rows:
		for i in width:
			$Placed.erase_cell(top_left + Vector2i(i, j))
	

func let_go():
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
			clear_area(Vector2i(1,17), 4, 4, $Placed)
		1:
			clear_area(Vector2i(6,17), 4, 4, $Placed)
		2:
			clear_area(Vector2i(11,17), 4, 4, $Placed)
func move_piece(piece, slot):
	dragging_piece = piece
	dragging_slot = slot
	dragging = true
	draw_piece_offset(piece, Vector2i(0,0), piece.colour, $Move)
	clear_slot(slot)


# When a new piece is rotated, the old one is rotated due to how godot passed objects by reference
# Fixed
func get_random_piece():
	if not current_pieces.is_empty():
		current_pieces.shuffle()
	else:
		current_pieces = possible_pieces.duplicate()
		
	var piece: Piece = current_pieces.pop_front().clone()
	piece.rotate(rotations.pick_random())
	return piece
