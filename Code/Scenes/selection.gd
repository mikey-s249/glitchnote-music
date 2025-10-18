extends TileMapLayer
class_name SelectionController

signal block_selected(piece : Piece, block_id : int)

# How many tiles are between each selection box
const SELECTION_BOX_GAP = 5;

var _pieces: Array[Piece] = [null, null, null]
@onready var placed = %Placed

func set_piece(box_index : int, piece : Piece):
	_pieces[box_index] = piece;

func refresh_selection_box(box_index : int) -> void:
	var piece = PieceVerifier.get_random_piece(placed)
	assert (piece != null)
	set_piece(box_index, piece)

func get_piece(box_index : int) -> Piece:
	return _pieces[box_index];



# Draws the three main _pieces
func draw_pieces(slots = [0,1,2]):
	for slot in slots:
		TileDrawer.draw_piece_offset(_pieces[slot], Vector2i(1 + SELECTION_BOX_GAP * slot,1), _pieces[slot].colour, self)

func clear_slot(slot):
	TileDrawer.clear_area(Vector2i(1 + SELECTION_BOX_GAP * slot,1), 4, 4, self)



func _ready() -> void:
	for i in range(3):
		refresh_selection_box(i)
	draw_pieces()

func _on_block_selection(block_id: int) -> void:
	clear_slot(block_id)
	block_selected.emit(_pieces[block_id], block_id)


func _on_beat_dragging(dragging_slot) -> void:
	for piece: Piece in _pieces:
		piece.relative_rotate(Piece.RelativeRotation.RIGHT)
	
	var array = [0,1,2]
	array.erase(dragging_slot)
	for slot in array:
		clear_slot(slot)
	draw_pieces(array)
