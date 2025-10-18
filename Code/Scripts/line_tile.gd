extends Special

const WIDTH = PieceVerifier.WIDTH
const HEIGHT = PieceVerifier.HEIGHT
const TOP_LEFT : Vector2i = PieceVerifier.TOP_LEFT
const GRID_POS : Vector2i = PieceVerifier.GRID_POS

var vertical: bool = false

signal line

func _ready() -> void:
	special = Piece.SpecialTiles.LINE
	#vertical = [true, false].pick_random()
	if ! vertical:
		$Sprite2D.rotation_degrees = 90

func timeout():
	line.emit(coords, vertical)
	line_expl()

func line_expl():
	if vertical:
		TileDrawer.clear_area(Vector2i(coords.x, TOP_LEFT.y), 1, HEIGHT, get_parent())
	else:
		TileDrawer.clear_area(Vector2i(TOP_LEFT.x, coords.y), WIDTH, 1, get_parent())
