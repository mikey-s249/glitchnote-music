extends Node

class_name Piece


# Will store pieces shapes as absolute chain codes, however the codes will not be cyclic
# Provide a method to rotate chain code by adding to all numbers in array
# To fix alignment issues with different shapes, manually create an offset attribute which stores the offset the shape should have to align within certain bounds
# May not work if rotation is automatic

enum Rotation {NORTH = 0, SOUTH = 2, EAST = 4, WEST = 6}

enum RelativeRotation {LEFT = -2, RIGHT = 2}

enum SpecialTiles {NONE = -1, BOMB = 1, LINE = 2}

var special: SpecialTiles = SpecialTiles.NONE

var chain_code: Array
#var rotation = Rotation.NORTH
var colour: Vector2i

var random_colour = false

func rotate(rotation: Rotation):
	for i in range(len(chain_code)):
		chain_code[i] = (rotation + chain_code[i]) % 8

func relative_rotate(rotation: RelativeRotation):
	for i in range(len(chain_code)):
		chain_code[i] = (rotation + chain_code[i]) % 8

func clone():
	return Piece.new(chain_code.duplicate(), colour, special, random_colour)

func get_random_colour():
	return Vector2i(randi_range(0,15) ,0)

func get_width():
	var max_left = 0
	var point = 0
	var max_right = 0
	for i in chain_code:
		if i in [1,2,3]:
			point += 1
		if i in [5,6,7]:
			point -= 1
		max_left = min(max_left, point)
		max_right = max(max_right, point)
	return max_right - max_left + 1


func _init(chain_code_i, colour_i: Vector2i = Vector2i(0,0), special_i: SpecialTiles = SpecialTiles.NONE, ran_colour: bool = true):
	chain_code = chain_code_i
	colour = colour_i
	special = special_i
	random_colour = ran_colour
	if random_colour:
		colour = get_random_colour()
