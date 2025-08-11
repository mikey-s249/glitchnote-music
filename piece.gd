extends Node

class_name Piece


# Will store pieces shapes as absolute chain codes, however the codes will not be cyclic
# Provide a method to rotate chain code by adding to all numbers in array
# To fix alignment issues with different shapes, manually create an offset attribute which stores the offset the shape should have to align within certain bounds
# May not work if rotation is automatic

enum Rotation {NORTH = 0, SOUTH = 2, EAST = 4, WEST = 6}

enum RelativeRotation {LEFT = -2, RIGHT = 2}



var chain_code: Array
#var rotation = Rotation.NORTH
var colour: Vector2i

func rotate(rotation: Rotation):
	for i in range(len(chain_code)):
		chain_code[i] = (rotation + chain_code[i]) % 8

func relative_rotate(rotation: RelativeRotation):
	for i in range(len(chain_code)):
		chain_code[i] = (rotation + chain_code[i]) % 8

func clone():
	return Piece.new(chain_code.duplicate(), colour)


func _init(chain_code_i, colour_i: Vector2i):
	chain_code = chain_code_i
	colour = colour_i
