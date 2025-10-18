extends Node

# Stores the size of the board
const WIDTH : int = 8
const HEIGHT : int = WIDTH
# Stores the offset of the grid from the origin
const GRID_POS : Vector2i = Vector2i(1,1)
# Stores the position of the top left placable tile
const TOP_LEFT : Vector2i = GRID_POS + Vector2i(1,1)


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

var rotations = [Piece.Rotation.NORTH, Piece.Rotation.SOUTH, Piece.Rotation.WEST, Piece.Rotation.EAST]

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

func get_chain(piece : Piece) -> Array:
	var positions = []
	
	for i in piece.chain_code:
		positions.append(get_index_offset_from_chain_code(i))
		
	return positions


# Gets the offset that a piece needs to be drawn at so it never goes beyond the top left spot
func find_piece_offset(chain: Array, pos: Vector2i) -> Vector2i:
	var original_pos: Vector2i = pos
	var min_x = pos.x
	var min_y = pos.y
	for i in chain:
		pos += get_index_offset_from_chain_code(i)
		min_x = min(min_x, pos.x)
		min_y = min(min_y, pos.y)
	var offset = Vector2i(original_pos.x - min_x, original_pos.y - min_y)
	return offset
	

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
	
	
	
# Checks if it given piece can be placed anywhere on the grid
func check_if_piece_placable(piece: Piece, tilemap : TileMapLayer):
	var output = false
	
	
	for x in range(WIDTH):
		for y in range(HEIGHT):
			if check_chain_offset(Vector2i(x,y) + GRID_POS, piece.chain_code, tilemap):
				output = true
	return output
	

# When a new piece is rotated, the old one is rotated due to how godot passed objects by reference
# Fixed
func get_random_piece(tilemap : TileMapLayer):
	if not current_pieces.is_empty():
		current_pieces.shuffle()
	else:
		current_pieces = possible_pieces.duplicate()
		
	var piece: Piece = current_pieces.pop_front().clone()
	piece.rotate(rotations.pick_random())
	if check_if_piece_placable(piece, tilemap):
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
				if check_if_piece_placable(piece, tilemap):
					return piece
		piece = error_piece.clone()
		return piece
