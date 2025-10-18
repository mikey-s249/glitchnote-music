extends TileMapLayer
class_name SelectionController

signal block_selected(piece : Piece, block_id : int)

var pieces: Array[Piece] = [null, null, null]

@onready var placed = %Placed

func populate_selection_box(box_index : int, piece : Piece):
	pieces[box_index] = piece;

func refresh_selection_box(box_index : int) -> void:
	var piece = PieceVerifier.get_random_piece(placed)
	assert (piece != null)
	pieces[box_index] = piece

func get_piece(box_index : int) -> Piece:
	return pieces[box_index];
	
# Draws the three main pieces
func draw_pieces(slots = [0,1,2]):
	if 0 in slots:
		TileDrawer.draw_piece_offset(pieces[0], Vector2i(1,1), pieces[0].colour, self)
	if 1 in slots:
		TileDrawer.draw_piece_offset(pieces[1], Vector2i(6,1), pieces[1].colour, self)
	if 2 in slots:
		TileDrawer.draw_piece_offset(pieces[2], Vector2i(11,1), pieces[2].colour, self)
		

func clear_slot(slot):
	match slot:
		0:
			TileDrawer.clear_area(Vector2i(1,1), 4, 4, self)
		1:
			TileDrawer.clear_area(Vector2i(6,1), 4, 4, self)
		2:
			TileDrawer.clear_area(Vector2i(11,1), 4, 4, self)
			
			
func _ready() -> void:
	for i in range(3):
		refresh_selection_box(i)
	draw_pieces()

func _on_block_selection(block_id: int) -> void:
	clear_slot(block_id)
	
	block_selected.emit(pieces[block_id], block_id)

	
func _on_beat_dragging(dragging_slot) -> void:
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
