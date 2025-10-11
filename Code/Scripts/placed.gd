# Code from here
# https://www.reddit.com/r/godot/comments/10ql0ch/comment/lrg2fmg/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

extends TileMapLayer
class_name PlacedScenes

var scene_coords: Dictionary[Vector2i, Node] = {}

func _enter_tree():
	child_entered_tree.connect(_register_child)
	child_exiting_tree.connect(_unregister_child)

func _register_child(child: Special):
	await child.ready
	var coords = local_to_map(to_local(child.global_position))
	scene_coords[coords] = child
	child.coords = coords
	#child.set_meta("tile_coords", coords)
	if child.special == Piece.SpecialTiles.BOMB:
		child.connect("explode", get_parent().bomb_expl)
	if child.special == Piece.SpecialTiles.LINE:
		child.connect("line", get_parent().line_expl)

func _unregister_child(child):
	#scene_coords.erase(child.get_meta("tile_coords"))
	scene_coords.erase(child.coords)

func get_cell_scene(coords: Vector2i) -> Node:
	return scene_coords.get(coords, null)
