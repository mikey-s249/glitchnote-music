extends Node
class_name Sounds

var F1B1 = load("res://Assets/Music/Funk1Tracks/F1B1.wav")
var F1B2 = load("res://Assets/Music/Funk1Tracks/F1B2.wav")
var F1B3 = load("res://Assets/Music/Funk1Tracks/F1B3.wav")
var F1B4 = load("res://Assets/Music/Funk1Tracks/F1B4.wav")
var F1B5 = load("res://Assets/Music/Funk1Tracks/F1B5.wav")
var F1B6 = load("res://Assets/Music/Funk1Tracks/F1B6.wav")
var F1B7 = load("res://Assets/Music/Funk1Tracks/F1B7.wav")
var F1B8 = load("res://Assets/Music/Funk1Tracks/F1B8.wav")

var F1C1 = load("res://Assets/Music/Funk1Tracks/F1C1.wav")
var F1C2 = load("res://Assets/Music/Funk1Tracks/F1C2.wav")
var F1C3 = load("res://Assets/Music/Funk1Tracks/F1C3.wav")
var F1C4 = load("res://Assets/Music/Funk1Tracks/F1C4.wav")

var F1HH1 = load("res://Assets/Music/Funk1Tracks/F1HH1.wav")
var F1HH2 = load("res://Assets/Music/Funk1Tracks/F1HH2.wav")
var F1HH3 = load("res://Assets/Music/Funk1Tracks/F1HH3.wav")
var F1HH4 = load("res://Assets/Music/Funk1Tracks/F1HH4.wav")

var F1KS1 = load("res://Assets/Music/Funk1Tracks/F1KS1.wav")
var F1KS2 = load("res://Assets/Music/Funk1Tracks/F1KS2.wav")
var F1KS3 = load("res://Assets/Music/Funk1Tracks/F1KS3.wav")
var F1KS4 = load("res://Assets/Music/Funk1Tracks/F1KS4.wav")

var F1CM1 = load("res://Assets/Music/Funk1Tracks/F1CM1.wav")
var F1CM2 = load("res://Assets/Music/Funk1Tracks/F1CM2.wav")
var F1CM3 = load("res://Assets/Music/Funk1Tracks/F1CM3.wav")
var F1CM4 = load("res://Assets/Music/Funk1Tracks/F1CM4.wav")
var F1CM5 = load("res://Assets/Music/Funk1Tracks/F1CM5.wav")
var F1CM6 = load("res://Assets/Music/Funk1Tracks/F1CM6.wav")
var F1CM7 = load("res://Assets/Music/Funk1Tracks/F1CM7.wav")
var F1CM8 = load("res://Assets/Music/Funk1Tracks/F1CM8.wav")


var F1M1 = load("res://Assets/Music/Funk1Tracks/F1M1.wav")
var F1M2 = load("res://Assets/Music/Funk1Tracks/F1M2.wav")
var F1M3 = load("res://Assets/Music/Funk1Tracks/F1M3.wav")
var F1M4 = load("res://Assets/Music/Funk1Tracks/F1M4.wav")
var F1M5 = load("res://Assets/Music/Funk1Tracks/F1M5.wav")
var F1M6 = load("res://Assets/Music/Funk1Tracks/F1M6.wav")


var bass = [F1B1, F1B2, F1B3, F1B4, F1B5, F1B6, F1B7, F1B8]
var chords = [F1C1, F1C2, F1C3, F1C4]
var high_hats = [F1HH1, F1HH2, F1HH3, F1HH4]
var drums = [F1KS1, F1KS2, F1KS3, F1KS4]
var melody = [F1M1, F1M2, F1M3, F1M4, F1M5, F1M6]
var counter_melody = [F1CM1, F1CM2, F1CM3, F1CM4, F1CM5, F1CM6, F1CM7, F1CM8]

enum Type{BASS, CHORDS, HIGH_HATS, DRUMS, MELODY, COUNTER_MELODY}

var idle_bg = StyleBoxFlat.new()
var idle_fill = StyleBoxFlat.new()

var playing_fill = StyleBoxFlat.new()
var losing_fill = StyleBoxFlat.new()
# Stores pointers for all of the music tiles
var tiles: Array[Tiles] = []

# Stores pointers for all of the progress bars
var bars: Array[ProgressBar] = []

var styles: Array[StyleBoxFlat] = []

func get_new_melody(type):
	#var output
	match type:
		
		Type.BASS:
			#print("Bass")
			#output.resource_path.get_file()
			#return F1B5
			return bass.pick_random()
		Type.CHORDS:
			#print("Chords")
			
			return chords.pick_random()
		Type.HIGH_HATS:
			#print("High Hats")
			
			return high_hats.pick_random()
		Type.DRUMS:
			#print("Drums")
			
			return drums.pick_random()
		Type.MELODY:
			#print("Melody")
			
			return melody.pick_random()
		Type.COUNTER_MELODY:
			#print("Counter Melody")
			return counter_melody.pick_random()
			#return F1CM1
		_:
			print("Error")


func _ready() -> void:
	idle_bg.bg_color = Color("FFFFFF")
	idle_fill.bg_color = Color("ffffffff")
	playing_fill.bg_color = Color("ff2996")
	losing_fill.bg_color = Color("ff0000")
	
	for child in get_children():
		if child is Tiles:
			tiles.append(child)
			var style = StyleBoxFlat.new()
			style.bg_color = child.tile_color
			styles.append(style)
	for child in $ProgressBars.get_children():
		bars.append(child)
	
	for i in range(len(tiles)):
		bars[i].get_child(0).text = tiles[i].type_name
		
		
		
		
#func _on_music_clock_timeout() -> void:
	#for i in range(len(tiles)):
		#if tiles[i].state == Tiles.TileState.IDLE or tiles[i].state == Tiles.TileState.READY:
			#bars[i].add_theme_stylebox_override("background", idle_bg)
			#bars[i].add_theme_stylebox_override("fill", idle_fill)
			#bars[i].value = 0
		#elif tiles[i].state == Tiles.TileState.PLAYING:
			#bars[i].add_theme_stylebox_override("fill", playing_fill)
			#bars[i].value = tiles[i].get_frac() * 100
		#else:
			#bars[i].add_theme_stylebox_override("fill", losing_fill)
			#bars[i].value = tiles[i].get_frac() * 100


func _process(delta: float) -> void:
	for i in range(len(tiles)):
		if tiles[i].state == Tiles.TileState.IDLE or tiles[i].state == Tiles.TileState.READY:
			bars[i].add_theme_stylebox_override("background", idle_bg)
			bars[i].add_theme_stylebox_override("fill", idle_fill)
			bars[i].value = 0
		elif tiles[i].state == Tiles.TileState.PLAYING:
			bars[i].add_theme_stylebox_override("fill", styles[i])
			bars[i].value = tiles[i].get_frac() * 100
		else:
			bars[i].add_theme_stylebox_override("fill", losing_fill)
			bars[i].value = tiles[i].get_frac() * 100
