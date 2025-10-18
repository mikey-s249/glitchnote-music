extends Special

const TILE_WIDTH : int = TileDrawer.TILE_WIDTH
var explode_particle_scene = preload("res://Code/Scenes/explode_effect.tscn")


signal bomb_explode(coords : Vector2i)
signal camera_shake(time : float)

enum BombStates{INACTIVE, ACTIVE}

var state = BombStates.INACTIVE

func _ready() -> void:
	special = Piece.SpecialTiles.BOMB

func timeout():
	bomb_explode.emit(coords)
	bomb_expl()
	
func bomb_expl():
	var particle = explode_particle_scene.instantiate()
	var tilemap : TileMapLayer = get_parent();
	
	particle.global_position = tilemap.to_global(tilemap.map_to_local(coords)) + (0.5 * Vector2(TILE_WIDTH, -TILE_WIDTH))
	add_sibling(particle)
	particle.restart()
	camera_shake.emit(0.2)
	
	TileDrawer.clear_area(coords-Vector2i(1,1), 3, 3, tilemap)
