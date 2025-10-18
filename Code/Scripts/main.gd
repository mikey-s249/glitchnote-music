extends Node2D

var time_count = 0

# This signal emits every end of the beat
#	but includes which slot is currently being dragged
signal beat_dragging(draggin_slot : int)

const WIDTH = PieceVerifier.WIDTH
const HEIGHT = PieceVerifier.HEIGHT
const TOP_LEFT : Vector2i = PieceVerifier.TOP_LEFT
const GRID_POS : Vector2i = PieceVerifier.GRID_POS
const TILE_ID : int = TileDrawer.TILE_ID

# Stores the initial size of an individual tile before scaling has taken place
var tile_size = 32
# Stores the size an individual tile after scaling has taken place
var scaled_tile_size

# Stores the tile that the grid is made of
var grid_colour = Vector2i(14, 0)

var dragging_piece_offset

# Stores the coordinates of bomb blocks
#var bomb_coords = []

var score = 0


# Need to fix:
# 	Able to place tiles outside of play area --
# 	When a new piece is the same as a another one you currently hold, the other one gets rotated to match the rotation --
# 	Centering of particles emitted when line is cleared --

var particle_scene = preload("res://Code/Scenes/burst_particle.tscn")
var tile_ray_scene = preload("res://Code/Scenes/tile_ray.tscn")
var explode_particle_scene = preload("res://Code/Scenes/explode_effect.tscn")

@onready var selection_controller = %Selection as SelectionController
@onready var selection_layer : TileMapLayer = %Selection
@onready var placed_layer : TileMapLayer = %Placed
@onready var ghost_layer : TileMapLayer = %Ghost
@onready var move_layer : TileMapLayer = %Move


# Keeps track of whether a piece is being dragged currently or not
var dragging = false

# The piece that is currently being dragged
var dragging_piece: Piece

# The slot that is currently being used
var dragging_slot
# Initial position of Move layer
var default_position


# Clears an area specified by a chain code
#func clear_chain(pos: Vector2i, chain_code: Array[int], layer: TileMapLayer):
	#layer.erase_cell(pos)
	#
	#for i in chain_code:
		#pos += get_index_offset_from_chain_code(i)
		#layer.erase_cell(pos)



# Checks if the lines need clearing
func check_lines():
	var rows: Array
	var columns: Array
	var passed = true
	for i in range(WIDTH):
		passed = true
		for j in range(HEIGHT):
			passed = placed_layer.get_cell_atlas_coords(TOP_LEFT + Vector2i(i,j)) != Vector2i(-1,-1)
			if ! passed:
				break
		if passed:
			columns.append(i)
	
	for j in range(WIDTH):
		passed = true
		for i in range(HEIGHT):
			passed = placed_layer.get_cell_atlas_coords(TOP_LEFT + Vector2i(i,j)) != Vector2i(-1,-1)
			if ! passed:
				break
		if passed:
			rows.append(j)
	
	score += (rows.size() + columns.size()) * 100
	
	
	for i in columns:
		gen_ray(TileRay.Direction.VERTICAL, Vector2i(i, 0))
		var particle = particle_scene.instantiate()
		particle.global_position = placed_layer.to_global(placed_layer.map_to_local(TOP_LEFT + Vector2i(i, WIDTH/2)))
		if WIDTH % 2 == 0:
			particle.global_position.y -= placed_layer.scale.y * tile_size / 2 
		add_sibling(particle)
		particle.start()
		$Camera.shakeTimed(0.2)
		for j in HEIGHT:
			placed_layer.erase_cell(TOP_LEFT + Vector2i(i, j))
			#if TOP_LEFT + Vector2i(i,j) in bomb_coords:
				#bomb_coords.erase(TOP_LEFT + Vector2i(i,j))
		
	for j in rows:
		gen_ray(TileRay.Direction.HORIZONTAL, Vector2i(0, j))
		
		var particle: Node2D = particle_scene.instantiate()
		
		particle.global_position = placed_layer.to_global(placed_layer.map_to_local(TOP_LEFT + Vector2i(HEIGHT/2, j)))
		if HEIGHT % 2 == 0:
			particle.global_position.x -= placed_layer.scale.x * tile_size / 2 
		
		particle.rotate_particles(90)
		add_sibling(particle)
		$Camera.shakeTimed(0.2)
		particle.start()
		for i in WIDTH:
			placed_layer.erase_cell(TOP_LEFT + Vector2i(i, j))
			#if TOP_LEFT + Vector2i(i,j) in bomb_coords:
				#bomb_coords.erase(TOP_LEFT + Vector2i(i,j))



func _ready():
	scaled_tile_size = placed_layer.tile_set.tile_size.x * placed_layer.scale.x	
	
	#print(scaled_tile_size)
	#create_board()

	default_position = move_layer.global_position
	for node in $MusicTiles.get_children():
		node.connect("lose_game", game_lose)



func _process(delta: float):
	$ScoreLabel.text = "Score: " + str(score)
	var cell_coords

	if dragging:
		move_layer.global_position = get_global_mouse_position()
		ghost_layer.clear()

		move_layer.global_position.x -= dragging_piece_offset
		cell_coords = ghost_layer.local_to_map(ghost_layer.to_local(move_layer.global_position))
		cell_coords.y -= 3
		move_layer.global_position -= (ghost_layer.map_to_local(Vector2i(0,3)))

		if 2 <= cell_coords.x and cell_coords.x <= 9 and 2 <= cell_coords.y and cell_coords.y <= 9: 
			if PieceVerifier.check_chain_offset(cell_coords, dragging_piece.chain_code, placed_layer):
				TileDrawer.draw_piece_offset(dragging_piece, cell_coords, dragging_piece.colour + Vector2i(0,1), ghost_layer)
		
		
		if Input.is_action_just_released("left_click"):
			if PieceVerifier.check_chain_offset(cell_coords, dragging_piece.chain_code, placed_layer) and 2 <= cell_coords.x and cell_coords.x <= 9 and 2 <= cell_coords.y and cell_coords.y <= 9:
				TileDrawer.draw_piece_offset(dragging_piece, cell_coords, dragging_piece.colour, placed_layer)
				#if dragging_piece.can_explode:
					#bomb_coords.append(cell_coords)
				
				selection_controller.refresh_selection_box(dragging_slot);
				check_lines()
			dragging = false
			move_layer.global_position = default_position
			ghost_layer.clear()
			let_go()



func let_go():
	dragging_piece = null
	dragging_slot = null
	selection_controller.draw_pieces();
	TileDrawer.clear_area(Vector2i(0,0), 4, 4, move_layer)

func _on_block_selected(piece : Piece, block_id: int) -> void:
	move_piece(piece, block_id)
	



func move_piece(piece, slot):
	dragging_piece = piece
	dragging_slot = slot
	dragging = true
	dragging_piece_offset = ((dragging_piece.get_width() * 0.5) - 0.5) * scaled_tile_size
	update_move_piece()
	

func update_move_piece():
	if dragging_piece != null:
		TileDrawer.clear_area(Vector2i(0,0), 4, 4, move_layer)
		TileDrawer.draw_piece_offset(dragging_piece, Vector2i(0,0), dragging_piece.colour, move_layer)
		dragging_piece_offset = ((dragging_piece.get_width() * 0.5) - 0.5) * scaled_tile_size
		
	



# Function to create the board based on the WIDTH and HEIGHT values
# Scales board to fit in the 
func create_board():
	for i in range(WIDTH+2):
		placed_layer.set_cell(Vector2i(i,0) + GRID_POS, TILE_ID, grid_colour)
		placed_layer.set_cell(Vector2i(i,HEIGHT+1) + GRID_POS, TILE_ID, grid_colour)
	for i in range(HEIGHT+2):
		placed_layer.set_cell(Vector2i(0,i) + GRID_POS, TILE_ID, grid_colour)
		placed_layer.set_cell(Vector2i(WIDTH+1,i) + GRID_POS, TILE_ID, grid_colour)
	var edge_coords = placed_layer.to_global(placed_layer.map_to_local(Vector2i(WIDTH+2,0) + GRID_POS)).x - tile_size / 2
	var screen_edge = get_viewport().content_scale_size.x
	var scale = screen_edge / edge_coords
	placed_layer.scale = Vector2(scale, scale)
	move_layer.scale = Vector2(scale, scale)
	ghost_layer.scale = Vector2(scale, scale)
	
	var bottom_placed_coords = placed_layer.to_global(placed_layer.map_to_local(Vector2i(0, HEIGHT + 2) + GRID_POS)).y - (tile_size / 2) - 3
	#var top_selection_coords = selection_layer.to_global(selection_layer.map_to_local(Vector2i()))
	#print(bottom_placed_coords)
	selection_layer.global_position.y = bottom_placed_coords
	
	#print(placed_layer.to_global(placed_layer.map_to_local(Vector2i(WIDTH+2,1))).x)
	print(scale)


func gen_ray(direction: TileRay.Direction, coords: Vector2i) -> void:
	var pos = placed_layer.to_global(placed_layer.map_to_local(coords + TOP_LEFT))
	var ray = tile_ray_scene.instantiate()
	ray.set_direction(direction)
	#print(pos)
	#if direction == TileRay.Direction.VERTICAL:
	ray.global_position = pos
	add_child(ray)



func _on_music_clock_timeout() -> void:
	time_count += 1
	time_count %= 4
	
	for node in $MusicTiles.get_children():
		if node is Tiles:
			node.clock_timeout()
		
	for node: Special in placed_layer.get_children():
		node.timeout()
	#for coord in bomb_coords:
		#var particle = explode_particle_scene.instantiate()
		#particle.global_position = placed_layer.to_global(placed_layer.map_to_local(coord))
		#add_sibling(particle)
		#particle.restart()
		#$Camera.shakeTimed(0.2)
		#for i in range(coord.x-1, coord.x+2):
			#for j in range(coord.y-1, coord.y+2):
				#if 2 <= i and i <= 9 and 2 <= j and j <= 9:
					#placed_layer.erase_cell(Vector2i(i,j))
	#bomb_coords.clear()



func bomb_expl(coords: Vector2i):
	var particle = explode_particle_scene.instantiate()
	particle.global_position = placed_layer.to_global(placed_layer.map_to_local(coords))
	add_sibling(particle)
	particle.restart()
	$Camera.shakeTimed(0.2)
	for i in range(coords.x-1, coords.x+2):
		for j in range(coords.y-1, coords.y+2):
			if TOP_LEFT.x <= i and i <= TOP_LEFT.x + WIDTH - 1 and TOP_LEFT.y <= j and j <= TOP_LEFT.y + HEIGHT - 1:
				placed_layer.erase_cell(Vector2i(i,j))

func line_expl(coords: Vector2i, vertical: bool):
	if vertical:
		for i in range(TOP_LEFT.y, TOP_LEFT.y + HEIGHT):
			placed_layer.erase_cell(Vector2i(coords.x, i))
	else:
		for i in range(TOP_LEFT.x, TOP_LEFT.x + WIDTH):
			placed_layer.erase_cell(Vector2i(i, coords.y))


func _on_beat_timer_timeout() -> void:
	beat_dragging.emit(dragging_slot)
	update_move_piece()

func _on_can_lose_timer_timeout() -> void:
	for node in $MusicTiles.get_children():
		if node is Tiles:
			node.can_lose = true

func game_lose():
	print("Fuck you, you lose")


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
