extends TileMapLayer
class_name SelectionController

signal block_selected(piece : Piece, block_id : int)
signal draw_piece_offset(piece : Piece, offset : Vector2i, colour : Vector2i, layer : TileMapLayer)

var pieces: Array[Piece] = [null, null, null]

@onready var placed = %Placed

func populate_selection_box(box_index : int, piece : Piece):
	pieces[box_index] = piece;

func refresh_selection_box(box_index : int) -> void:
	var piece = PieceVerifier.get_random_piece(placed)
	assert (piece != null)
	pieces[box_index] = piece

# Draws the three main pieces
func draw_pieces(slots = [0,1,2]):
	if 0 in slots:
		draw_piece_offset.emit(pieces[0], Vector2i(1,1), pieces[0].colour, self)
	if 1 in slots:
		draw_piece_offset.emit(pieces[1], Vector2i(6,1), pieces[1].colour, self)
	if 2 in slots:
		draw_piece_offset.emit(pieces[2], Vector2i(11,1), pieces[2].colour, self)
		
		
func _ready() -> void:
	for i in range(3):
		refresh_selection_box(i)
	draw_pieces()

func _on_block_selection(block_id: int) -> void:
	block_selected.emit(pieces[block_id], block_id)


func _on_beat_timer_timeout() -> void:
	
	for piece: Piece in pieces:
		piece.relative_rotate(Piece.RelativeRotation.RIGHT)
