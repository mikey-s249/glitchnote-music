extends Node2D

class_name Special

var special: Piece.SpecialTiles = Piece.SpecialTiles.NONE

var coords: Vector2i

func timeout() -> void:
	pass
	
func set_coords(new_coords : Vector2i):
	coords = new_coords
