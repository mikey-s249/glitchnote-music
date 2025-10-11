extends Special

signal explode

enum BombStates{INACTIVE, ACTIVE}


var state = BombStates.INACTIVE

func _ready() -> void:
	special = Piece.SpecialTiles.BOMB

func timeout():
	explode.emit(coords)
