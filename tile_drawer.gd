extends Node

# Stores the id for the tileset
const TILE_ID: int = 2
const TILE_WIDTH : int = 32

# Stores the id for the tileset with the special tiles
const SPECIAL_ID: int = 3


# Draws a piece specified by a chain code
func draw_piece(piece: Piece, pos: Vector2i, colour: Vector2i, layer: TileMapLayer, tile_source_id=TILE_ID):
	
	layer.set_cell(pos, tile_source_id, colour)
	var chain = PieceVerifier.get_chain(piece)
	
	for offset in chain:
		pos += offset
		layer.set_cell(pos, tile_source_id, colour)

# Draws a piece that uses special tiles
func draw_special_piece(piece: Piece, pos: Vector2i, special: Piece.SpecialTiles, layer: TileMapLayer):
	layer.set_cell(pos, SPECIAL_ID, Vector2i.ZERO, piece.special)
	var chain = PieceVerifier.get_chain(piece)
	
	for offset in chain:
		pos += offset
		layer.set_cell(pos, SPECIAL_ID, Vector2i.ZERO, piece.special)

# Draws a piece using the offset
func draw_piece_offset(piece: Piece, pos: Vector2i, colour: Vector2i, layer: TileMapLayer, tile_source_id=TILE_ID):
	pos += PieceVerifier.find_piece_offset(piece.chain_code, pos)
	
	assert(layer != null)
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
