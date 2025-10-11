extends Special


var vertical: bool = false

signal line

func _ready() -> void:
	special = Piece.SpecialTiles.LINE
	#vertical = [true, false].pick_random()
	if ! vertical:
		$Sprite2D.rotation_degrees = 90


func timeout():
	line.emit(coords, vertical)
